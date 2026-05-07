import 'package:hive/hive.dart';
import 'package:waternode/features/devices/domain/models/device_station.dart';
import 'package:waternode/features/devices/domain/repositories/device_station_cache_repository.dart';

class HiveDeviceStationCacheRepository implements DeviceStationCacheRepository {
  HiveDeviceStationCacheRepository(this._box);

  static const boxName = 'device_station_cache';

  final Box<dynamic> _box;

  @override
  Future<List<DeviceStation>> readStations({required String accountKey}) async {
    final rawStations = _box.get(accountKey);
    if (rawStations == null) {
      return const <DeviceStation>[];
    }
    if (rawStations is! List) {
      throw StateError('设备缓存格式错误: $accountKey');
    }
    return rawStations
        .map((dynamic item) => _mapStationEntry(item, accountKey))
        .toList(growable: false);
  }

  @override
  Future<void> saveStations({
    required String accountKey,
    required List<DeviceStation> stations,
  }) async {
    final payload = stations
        .map((station) => station.toMap())
        .toList(growable: false);
    await _box.put(accountKey, payload);
  }

  DeviceStation _mapStationEntry(dynamic item, String accountKey) {
    if (item is! Map) {
      throw StateError('设备缓存条目格式错误: $accountKey');
    }
    return DeviceStation.fromMap(item);
  }
}
