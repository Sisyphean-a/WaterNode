import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/devices/domain/models/device_station.dart';
import 'package:waternode/features/devices/domain/models/free_water_config.dart';

abstract interface class DeviceGateway {
  Future<FreeWaterConfig> getFreeWaterConfig(AccountCredential credential);

  Future<List<DeviceStation>> getWaterStations({
    required String regionCode,
    required AccountCredential credential,
  });

  Future<DeviceStation> getStationDetail({
    required String stationId,
    required AccountCredential credential,
  });

  Future<void> dispenseWater({
    required String stationId,
    required int quantity,
    required AccountCredential credential,
  });
}
