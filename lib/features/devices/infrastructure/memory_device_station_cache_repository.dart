import 'package:waternode/features/devices/domain/models/device_station.dart';
import 'package:waternode/features/devices/domain/repositories/device_station_cache_repository.dart';

class MemoryDeviceStationCacheRepository
    implements DeviceStationCacheRepository {
  final Map<String, List<DeviceStation>> _storage =
      <String, List<DeviceStation>>{};

  @override
  Future<List<DeviceStation>> readStations({required String accountKey}) async {
    return _storage[accountKey] ?? const <DeviceStation>[];
  }

  @override
  Future<void> saveStations({
    required String accountKey,
    required List<DeviceStation> stations,
  }) async {
    _storage[accountKey] = List<DeviceStation>.unmodifiable(stations);
  }
}
