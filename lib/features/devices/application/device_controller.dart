import 'package:get/get.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/dashboard/domain/models/task_log_entry.dart';
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
    const RegionOption(code: 'default-page', name: '更多设备列表'),
  ].obs;

  final selectedSource = Rxn<RegionOption>();
  final selectedCredential = Rxn<AccountCredential>();
  final selectedStation = Rxn<DeviceStation>();
  final freeWaterConfig = Rxn<FreeWaterConfig>();
  final stations = <DeviceStation>[].obs;
  final logs = <TaskLogEntry>[].obs;
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
    _selectDefaultSource(credential).then((_) {
      loadStations().catchError((_) {});
    });
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
    if (sources.isEmpty) {
      stations.clear();
      selectedStation.value = null;
      freeWaterConfig.value = null;
      return;
    }

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
      final preferredSource = selectedSource.value ?? sources.first;
      selectedSource.value = preferredSource;
      final loadedStations = await _loadAllStations(
        credential,
        preferredSourceCode: preferredSource.code,
      );
      freeWaterConfig.value = config;
      stations.assignAll(loadedStations);
      _restoreSelectedStation();
    } catch (error) {
      lastError.value = error.toString();
      stations.clear();
      selectedStation.value = null;
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
      _addLog(
        '${credential.mobile} 对 ${detail.name} 取水成功 '
        '${_displayVolumeLabel(quantity, config)}',
      );
    } catch (error) {
      final message = error.toString();
      final stationName = targetStation.name;
      if (message.contains('超出每日取水')) {
        final limitMessage = '当前账号当日取水额度已耗尽，可切换其他账号继续操作';
        lastError.value = limitMessage;
        _addLog(
          '${credential.mobile} 对 $stationName 取水失败: $limitMessage',
          isError: true,
        );
        throw StateError(limitMessage);
      }
      lastError.value = message;
      _addLog(
        '${credential.mobile} 对 $stationName 取水失败: $error',
        isError: true,
      );
      rethrow;
    } finally {
      dispatchingStationId.value = null;
    }
  }

  void selectStationById(String stationId) {
    final station = stations.firstWhereOrNull((item) => item.id == stationId);
    if (station == null) {
      throw StateError('没有找到设备 $stationId');
    }
    selectedStation.value = station;
  }

  Future<void> _selectDefaultSource(AccountCredential credential) async {
    selectedSource.value = sources.firstOrNull;
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
    final selected = selectedStation.value;
    if (selected != null) {
      return selected;
    }
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

  void _addLog(String message, {bool isError = false}) {
    logs.insert(
      0,
      TaskLogEntry(
        message: message,
        createdAt: DateTime.now(),
        isError: isError,
      ),
    );
  }

  void _restoreSelectedStation() {
    final currentStationId = selectedStation.value?.id;
    final restoredStation = stations.firstWhereOrNull(
      (item) => item.id == currentStationId,
    );
    selectedStation.value =
        restoredStation ??
        _defaultStation(preferredRegionCode: selectedSource.value?.code);
  }

  DeviceStation? _defaultStation({String? preferredRegionCode}) {
    final preferredOnline = stations.firstWhereOrNull(
      (item) => item.regionCode == preferredRegionCode && item.isOnline,
    );
    if (preferredOnline != null) {
      return preferredOnline;
    }
    final preferredAny = stations.firstWhereOrNull(
      (item) => item.regionCode == preferredRegionCode,
    );
    if (preferredAny != null) {
      return preferredAny;
    }
    return stations.firstWhereOrNull((item) => item.isOnline) ??
        stations.firstOrNull;
  }

  Future<List<DeviceStation>> _loadAllStations(
    AccountCredential credential, {
    required String preferredSourceCode,
  }) async {
    final mergedStations = <String, DeviceStation>{};
    for (final source in sources) {
      final sourceStations = await _deviceGateway.getWaterStations(
        regionCode: source.code,
        credential: credential,
      );
      for (final station in sourceStations) {
        mergedStations.putIfAbsent(station.id, () => station);
      }
    }
    final stationsList = mergedStations.values.toList(growable: false);
    stationsList.sort(
      (left, right) => _compareStations(
        left,
        right,
        preferredSourceCode: preferredSourceCode,
      ),
    );
    return stationsList;
  }

  int _compareStations(
    DeviceStation left,
    DeviceStation right, {
    required String preferredSourceCode,
  }) {
    final leftPriority = _stationPriority(
      left,
      preferredSourceCode: preferredSourceCode,
    );
    final rightPriority = _stationPriority(
      right,
      preferredSourceCode: preferredSourceCode,
    );
    if (leftPriority != rightPriority) {
      return leftPriority.compareTo(rightPriority);
    }
    return left.name.compareTo(right.name);
  }

  int _stationPriority(
    DeviceStation station, {
    required String preferredSourceCode,
  }) {
    if (station.regionCode == preferredSourceCode && station.isOnline) {
      return 0;
    }
    if (station.regionCode == preferredSourceCode) {
      return 1;
    }
    if (station.isOnline) {
      return 2;
    }
    return 3;
  }
}
