import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/devices/domain/gateways/device_gateway.dart';
import 'package:waternode/features/devices/domain/models/device_station.dart';
import 'package:waternode/features/devices/domain/models/free_water_config.dart';

class MemoryDeviceGateway implements DeviceGateway {
  const MemoryDeviceGateway();

  @override
  Future<void> dispenseWater({
    required String stationId,
    required int quantity,
    required AccountCredential credential,
  }) async {}

  @override
  Future<FreeWaterConfig> getFreeWaterConfig(
    AccountCredential credential,
  ) async {
    return const FreeWaterConfig(
      id: 'memory-config',
      beanValue: 200,
      waterVolume: 7.5,
      dayLimit: 2,
      isOn: true,
    );
  }

  @override
  Future<DeviceStation> getStationDetail({
    required String stationId,
    required AccountCredential credential,
  }) async {
    return _stations.firstWhere((station) => station.id == stationId);
  }

  @override
  Future<List<DeviceStation>> getWaterStations({
    required String regionCode,
    required AccountCredential credential,
  }) async {
    return _stations
        .where((station) => station.regionCode == regionCode)
        .toList(growable: false);
  }

  static const List<DeviceStation> _stations = <DeviceStation>[
    DeviceStation(
      id: 'memory-in-village-01',
      name: '冯塘乡丁洼村',
      status: 'ONLINE',
      regionCode: 'in-village',
      deviceNum: '864708065296769',
      address: '超市门口',
      isOnline: true,
      dispenserType: 'ALL_FREE',
      dispenserTypeDesc: '全部免费',
      statusDescription: '水箱水量192L',
    ),
    DeviceStation(
      id: 'memory-default-01',
      name: '卫贤姜含珠',
      status: 'ONLINE',
      regionCode: 'default-page',
      deviceNum: '865096063551420',
      address: '卫贤镇姜含珠',
      isOnline: true,
      dispenserType: 'ALL_FREE',
      dispenserTypeDesc: '全部免费',
      distanceKm: 0,
    ),
  ];
}
