import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/devices/domain/models/device_station.dart';

abstract interface class DeviceGateway {
  Future<List<DeviceStation>> getWaterStations(String regionCode);

  Future<void> dispenseWater({
    required String stationId,
    required int volume,
    required AccountCredential credential,
  });
}
