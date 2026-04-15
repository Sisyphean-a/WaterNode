import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/devices/domain/gateways/device_gateway.dart';
import 'package:waternode/features/devices/domain/models/device_station.dart';

class DeviceApi implements DeviceGateway {
  @override
  Future<List<DeviceStation>> getWaterStations(String regionCode) {
    throw UnimplementedError('getWaterStations 接口未接入');
  }

  @override
  Future<void> dispenseWater({
    required String stationId,
    required int volume,
    required AccountCredential credential,
  }) {
    throw UnimplementedError('dispenseWater 接口未接入');
  }
}
