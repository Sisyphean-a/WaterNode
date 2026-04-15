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
  final freeWaterConfig = Rxn<FreeWaterConfig>();
  final stations = <DeviceStation>[].obs;
  final logs = <String>[].obs;
  final isLoading = false.obs;
  final dispatchingStationId = RxnString();
  final lastError = RxnString();

  @override
  void onInit() {
    super.onInit();
    selectedSource.value = sources.first;
    _initializeStations();
  }

  void selectSource(RegionOption? source) {
    if (source == null) {
      return;
    }
    selectedSource.value = source;
    _initializeStations();
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
      final credential = _findQueryCredential();
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

  Future<void> sendCommand(DeviceStation station) async {
    await _credentialController.refreshStatuses();
    final credential = _findDispatchCredential();
    final config =
        freeWaterConfig.value ??
        await _deviceGateway.getFreeWaterConfig(credential);
    dispatchingStationId.value = station.id;
    try {
      final detail = await _deviceGateway.getStationDetail(
        stationId: station.id,
        credential: credential,
      );
      await _deviceGateway.dispenseWater(
        stationId: station.id,
        quantity: 1,
        credential: credential,
      );
      logs.insert(
        0,
        '${credential.mobile} 对 ${detail.name} 取水成功 '
        '${config.waterVolume.toStringAsFixed(1)}L',
      );
    } catch (error) {
      logs.insert(0, '${station.name} 取水失败: $error');
      rethrow;
    } finally {
      dispatchingStationId.value = null;
    }
  }

  void _initializeStations() {
    loadStations().catchError((_) {});
  }

  AccountCredential _findQueryCredential() {
    return _credentialController.credentials.firstWhere(
      (item) => item.isValid,
      orElse: () => throw StateError('没有可用的有效账号用于加载设备列表'),
    );
  }

  AccountCredential _findDispatchCredential() {
    return _credentialController.credentials.firstWhere(
      (item) => item.isValid && item.points > 0,
      orElse: () => throw StateError('没有可用的有效积分账号'),
    );
  }
}
