import 'package:get/get.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/devices/domain/gateways/device_gateway.dart';
import 'package:waternode/features/devices/domain/models/device_station.dart';
import 'package:waternode/features/devices/domain/models/free_water_config.dart';
import 'package:waternode/features/devices/domain/models/region_option.dart';

class DeviceController extends GetxController {
  DeviceController(this._credentialController, this._deviceGateway);

  final CredentialController _credentialController;
  final DeviceGateway _deviceGateway;

  final sources = <RegionOption>[
    const RegionOption(code: 'in-village', name: '当前村设备'),
    const RegionOption(code: 'default-page', name: '默认分页设备'),
  ].obs;

  final selectedSource = Rxn<RegionOption>();
  final selectedCredential = Rxn<AccountCredential>();
  final freeWaterConfig = Rxn<FreeWaterConfig>();
  final stations = <DeviceStation>[].obs;
  final logs = <String>[].obs;
  final isLoading = false.obs;
  final dispatchingStationId = RxnString();
  final lastError = RxnString();

  @override
  void onInit() {
    super.onInit();
    prepareWorkbench().catchError((_) {});
  }

  void selectSource(RegionOption? source) {
    if (source == null) {
      return;
    }
    selectedSource.value = source;
    loadStations().catchError((_) {});
  }

  List<AccountCredential> get availableCredentials {
    final items = _credentialController.credentials
        .where((item) => item.isValid)
        .toList(growable: false);
    items.sort((left, right) => right.points.compareTo(left.points));
    return items;
  }

  Future<void> prepareWorkbench() async {
    try {
      await _credentialController.refreshStatuses();
      final credential = _resolveDefaultCredential();
      selectedCredential.value = credential;
      await _selectDefaultSource(credential);
      await loadStations();
    } catch (error) {
      lastError.value = error.toString();
      rethrow;
    }
  }

  void selectCredential(AccountCredential credential) {
    selectedCredential.value = credential;
  }

  Future<void> selectSourceByCode(String code) async {
    final source = sources.firstWhereOrNull((item) => item.code == code);
    if (source == null) {
      throw StateError('没有找到区域 $code');
    }
    selectedSource.value = source;
    final credential = selectedCredential.value;
    if (credential != null) {
      await _credentialController.updateAccountMeta(
        credential,
        defaultRegionCode: code,
      );
      selectedCredential.value = _credentialController.credentials.firstWhere(
        (item) => item.mobile == credential.mobile,
      );
    }
    await loadStations();
  }

  Future<void> loadStations() async {
    final source = selectedSource.value ?? sources.firstOrNull;
    if (source == null) {
      stations.clear();
      freeWaterConfig.value = null;
      return;
    }
    selectedSource.value = source;

    isLoading.value = true;
    lastError.value = null;
    try {
      await _credentialController.refreshStatuses();
      final credential = _resolveQueryCredential();
      selectedCredential.value = credential;
      final config = await _deviceGateway.getFreeWaterConfig(credential);
      if (!config.isOn) {
        throw StateError('免费接水活动未开启');
      }
      final loadedStations = await _deviceGateway.getWaterStations(
        regionCode: source.code,
        credential: credential,
      );
      freeWaterConfig.value = config;
      stations.assignAll(loadedStations);
    } catch (error) {
      lastError.value = error.toString();
      stations.clear();
      freeWaterConfig.value = null;
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendCommand({DeviceStation? station, int quantity = 1}) async {
    await _credentialController.refreshStatuses();
    final credential = _resolveDispatchCredential();
    final config =
        freeWaterConfig.value ??
        await _deviceGateway.getFreeWaterConfig(credential);
    final targetStation = station ?? _resolveTargetStation();
    dispatchingStationId.value = targetStation.id;
    try {
      final detail = await _deviceGateway.getStationDetail(
        stationId: targetStation.id,
        credential: credential,
      );
      await _deviceGateway.dispenseWater(
        stationId: targetStation.id,
        quantity: quantity,
        credential: credential,
      );
      logs.insert(
        0,
        '${credential.mobile} 对 ${detail.name} 取水成功 '
        '${_displayVolumeLabel(quantity, config)}',
      );
    } catch (error) {
      final message = error.toString();
      if (message.contains('超出每日取水')) {
        final limitMessage = '当前账号当日取水额度已耗尽，可切换其他账号继续操作';
        lastError.value = limitMessage;
        logs.insert(0, '${targetStation.name} 取水失败: $limitMessage');
        throw StateError(limitMessage);
      }
      lastError.value = message;
      logs.insert(0, '${targetStation.name} 取水失败: $error');
      rethrow;
    } finally {
      dispatchingStationId.value = null;
    }
  }

  Future<void> _selectDefaultSource(AccountCredential credential) async {
    final defaultSource =
        sources.firstWhereOrNull(
          (item) => item.code == credential.defaultRegionCode,
        ) ??
        sources.first;
    selectedSource.value = defaultSource;
  }

  AccountCredential _resolveDefaultCredential() {
    final credential = availableCredentials.firstOrNull;
    if (credential == null) {
      throw StateError('没有可用的有效账号用于加载设备列表');
    }
    return credential;
  }

  AccountCredential _resolveQueryCredential() {
    final selected = selectedCredential.value;
    if (selected != null && selected.isValid) {
      return selected;
    }
    return _resolveDefaultCredential();
  }

  AccountCredential _resolveDispatchCredential() {
    final selected = _resolveQueryCredential();
    if (selected.points > 0) {
      return selected;
    }
    throw StateError('当前账号积分不足，无法继续取水');
  }

  DeviceStation _resolveTargetStation() {
    final onlineStation = stations.firstWhereOrNull((item) => item.isOnline);
    return onlineStation ??
        stations.firstOrNull ??
        (throw StateError('当前区域没有可用设备'));
  }

  String _displayVolumeLabel(int quantity, FreeWaterConfig config) {
    if (quantity == 2) {
      return '15L';
    }
    return '${config.waterVolume.toStringAsFixed(1)}L';
  }
}
