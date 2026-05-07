import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:waternode/features/devices/domain/models/device_station.dart';
import 'package:waternode/features/devices/infrastructure/hive_device_station_cache_repository.dart';

void main() {
  late Directory tempDirectory;
  late Box<dynamic> box;
  late HiveDeviceStationCacheRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('waternode_station_');
    Hive.init(tempDirectory.path);
    box = await Hive.openBox<dynamic>('stations_test');
    repository = HiveDeviceStationCacheRepository(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('stations_test');
    await tempDirectory.delete(recursive: true);
  });

  test('persists and reloads stations for one account cache key', () async {
    const stations = <DeviceStation>[
      DeviceStation(
        id: 'device-1',
        name: '乡政府后院',
        status: 'ONLINE',
        regionCode: 'default-page',
        deviceNum: '861658061216167',
        address: '卫贤乡政府',
        isOnline: true,
        dispenserType: 'ALL_FREE',
        dispenserTypeDesc: '全部免费',
        latitude: 35.607226,
        longitude: 114.313807,
        distanceKm: 0,
      ),
    ];

    await repository.saveStations(
      accountKey: '15700000000',
      stations: stations,
    );

    final restored = await repository.readStations(accountKey: '15700000000');

    expect(restored, hasLength(1));
    expect(restored.single.id, 'device-1');
    expect(restored.single.name, '乡政府后院');
    expect(restored.single.latitude, 35.607226);
  });
}
