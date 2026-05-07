import 'package:waternode/features/devices/domain/models/device_station.dart';

abstract interface class DeviceStationCacheRepository {
  Future<List<DeviceStation>> readStations({required String accountKey});

  Future<void> saveStations({
    required String accountKey,
    required List<DeviceStation> stations,
  });
}
