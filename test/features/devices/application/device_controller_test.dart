import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/credentials/infrastructure/memory_account_repository.dart';
import 'package:waternode/features/dashboard/domain/gateways/activity_gateway.dart';
import 'package:waternode/features/dashboard/domain/models/account_bill.dart';
import 'package:waternode/features/dashboard/domain/models/account_status.dart';
import 'package:waternode/features/devices/application/device_controller.dart';
import 'package:waternode/features/devices/domain/gateways/device_gateway.dart';
import 'package:waternode/features/devices/domain/models/device_station.dart';
import 'package:waternode/features/devices/domain/models/free_water_config.dart';
import 'package:waternode/features/credentials/domain/models/account_sign_in_state.dart';

void main() {
  test(
    'defaults to highest-point account and prioritizes current-village device',
    () async {
      final repository = MemoryAccountRepository();
      await repository.save(
        const AccountCredential(
          mobile: '15700000000',
          token: 'token-query',
          platformType: 'CUSTOMER_APP',
          deviceId: 'device-query',
          userId: 'user-query',
          points: 2,
          isValid: true,
        ),
      );
      await repository.save(
        const AccountCredential(
          mobile: '15800000000',
          token: 'token-dispatch',
          platformType: 'CUSTOMER_APP',
          deviceId: 'device-dispatch',
          userId: 'user-dispatch',
          points: 8,
          isValid: true,
        ),
      );
      final credentialController = CredentialController(
        repository,
        _IdleActivityGateway(),
      );
      await credentialController.load();
      final gateway = _RecordingDeviceGateway();
      final controller = DeviceController(credentialController, gateway);

      await controller.prepareWorkbench();

      expect(controller.freeWaterConfig.value?.waterVolume, 7.5);
      expect(controller.stations, hasLength(2));
      expect(controller.selectedCredential.value?.mobile, '15800000000');
      expect(controller.selectedStation.value?.regionCode, 'in-village');
      expect(gateway.configCredentialMobile, '15800000000');
      expect(gateway.stationCredentialMobiles, contains('15800000000'));
      expect(controller.lastError.value, isNull);
    },
  );

  test(
    'dispatches selected water volume with selected account and records success log',
    () async {
      final repository = MemoryAccountRepository();
      await repository.save(
        const AccountCredential(
          mobile: '15700000000',
          token: 'token-query',
          platformType: 'CUSTOMER_APP',
          deviceId: 'device-query',
          userId: 'user-query',
          points: 0,
          isValid: true,
        ),
      );
      await repository.save(
        const AccountCredential(
          mobile: '15800000000',
          token: 'token-dispatch',
          platformType: 'CUSTOMER_APP',
          deviceId: 'device-dispatch',
          userId: 'user-dispatch',
          points: 3,
          isValid: true,
        ),
      );
      final credentialController = CredentialController(
        repository,
        _IdleActivityGateway(),
      );
      await credentialController.load();
      final gateway = _RecordingDeviceGateway();
      final controller = DeviceController(credentialController, gateway);
      await controller.prepareWorkbench();
      controller.selectCredential(
        controller.availableCredentials.firstWhere(
          (item) => item.mobile == '15800000000',
        ),
      );
      controller.selectStationById('device-2');

      await controller.sendCommand(quantity: 2);

      expect(gateway.detailCredentialMobile, '15800000000');
      expect(gateway.dispenseCredentialMobile, '15800000000');
      expect(gateway.dispenseStationId, 'device-2');
      expect(gateway.lastDispenseQuantity, 2);
      expect(controller.logs.first.message, contains('15800000000'));
      expect(controller.logs.first.message, contains('15L'));
    },
  );

  test(
    'dispatches to the station selected from the current station list',
    () async {
      final repository = MemoryAccountRepository();
      await repository.save(
        const AccountCredential(
          mobile: '15700000000',
          token: 'token-query',
          platformType: 'CUSTOMER_APP',
          deviceId: 'device-query',
          userId: 'user-query',
          points: 3,
          isValid: true,
        ),
      );
      final credentialController = CredentialController(
        repository,
        _IdleActivityGateway(),
      );
      await credentialController.load();
      final gateway = _MultiStationDeviceGateway();
      final controller = DeviceController(credentialController, gateway);

      await controller.prepareWorkbench();
      controller.selectStationById('device-2');
      await controller.sendCommand(quantity: 1);

      expect(gateway.detailStationId, 'device-2');
      expect(gateway.dispenseStationId, 'device-2');
      expect(controller.selectedStation.value?.id, 'device-2');
      expect(controller.logs.first.message, contains('卫贤姜含珠'));
    },
  );

  test('refreshes account balance before dispatching water', () async {
    final repository = MemoryAccountRepository();
    await repository.save(
      const AccountCredential(
        mobile: '15700000000',
        token: 'token-query',
        platformType: 'CUSTOMER_APP',
        deviceId: 'device-query',
        userId: 'user-query',
        points: 0,
        isValid: true,
      ),
    );
    final credentialController = CredentialController(
      repository,
      _RefreshingActivityGateway(),
    );
    await credentialController.load();
    final gateway = _RecordingDeviceGateway();
    final controller = DeviceController(credentialController, gateway);
    await controller.prepareWorkbench();

    await controller.sendCommand(quantity: 1);

    expect(gateway.dispenseCredentialMobile, '15700000000');
    expect(controller.logs.first.message, contains('15700000000'));
  });

  test(
    'marks quota-exhausted failure as business limit and keeps switching possible',
    () async {
      final repository = MemoryAccountRepository();
      await repository.save(
        const AccountCredential(
          mobile: '15700000000',
          token: 'token-query',
          platformType: 'CUSTOMER_APP',
          deviceId: 'device-query',
          userId: 'user-query',
          points: 5,
          isValid: true,
        ),
      );
      await repository.save(
        const AccountCredential(
          mobile: '15800000000',
          token: 'token-other',
          platformType: 'CUSTOMER_APP',
          deviceId: 'device-other',
          userId: 'user-other',
          points: 4,
          isValid: true,
        ),
      );
      final credentialController = CredentialController(
        repository,
        _IdleActivityGateway(),
      );
      await credentialController.load();
      final gateway = _QuotaFailureDeviceGateway();
      final controller = DeviceController(credentialController, gateway);

      await controller.prepareWorkbench();
      await expectLater(
        () => controller.sendCommand(quantity: 1),
        throwsA(isA<StateError>()),
      );
      expect(controller.lastError.value, contains('当日取水额度已耗尽'));
      expect(controller.lastError.value, contains('可切换其他账号'));
      expect(controller.availableCredentials, hasLength(2));
      expect(controller.logs.first.message, contains('15700000000'));
      expect(controller.logs.first.message, contains('取水失败'));
      expect(controller.logs.first.createdAt, isA<DateTime>());
    },
  );

  test(
    'logs explicit failure when no valid account can load device list',
    () async {
      final repository = MemoryAccountRepository();
      await repository.save(
        const AccountCredential(
          mobile: '15700000000',
          token: 'token-1',
          platformType: 'CUSTOMER_APP',
          deviceId: 'device-1',
          userId: 'user-1',
          points: 0,
          isValid: false,
        ),
      );
      final credentialController = CredentialController(
        repository,
        _IdleActivityGateway(),
      );
      await credentialController.load();
      final controller = DeviceController(
        credentialController,
        _RecordingDeviceGateway(),
      );

      await expectLater(
        controller.prepareWorkbench,
        throwsA(isA<StateError>()),
      );
      expect(controller.lastError.value, contains('没有可用的有效账号'));
    },
  );
}

class _IdleActivityGateway implements ActivityGateway {
  @override
  Future<AccountStatus> fetchStatus(AccountCredential credential) async {
    return AccountStatus(
      isValid: credential.isValid,
      points: credential.points,
      signInState: AccountSignInState.unknown,
    );
  }

  @override
  Future<List<AccountBill>> fetchBills(AccountCredential credential) async {
    return const <AccountBill>[];
  }

  @override
  Future<void> luckDraw(
    AccountCredential credential, {
    required String townCode,
  }) async {}

  @override
  Future<void> signIn(AccountCredential credential) async {}
}

class _RefreshingActivityGateway implements ActivityGateway {
  @override
  Future<AccountStatus> fetchStatus(AccountCredential credential) async {
    return const AccountStatus(
      isValid: true,
      points: 5,
      signInState: AccountSignInState.unknown,
    );
  }

  @override
  Future<List<AccountBill>> fetchBills(AccountCredential credential) async {
    return const <AccountBill>[];
  }

  @override
  Future<void> luckDraw(
    AccountCredential credential, {
    required String townCode,
  }) async {}

  @override
  Future<void> signIn(AccountCredential credential) async {}
}

class _RecordingDeviceGateway implements DeviceGateway {
  String? configCredentialMobile;
  final List<String> stationCredentialMobiles = <String>[];
  String? detailCredentialMobile;
  String? dispenseCredentialMobile;
  String? dispenseStationId;
  int? lastDispenseQuantity;

  @override
  Future<void> dispenseWater({
    required String stationId,
    required int quantity,
    required AccountCredential credential,
  }) async {
    dispenseCredentialMobile = credential.mobile;
    dispenseStationId = stationId;
    lastDispenseQuantity = quantity;
  }

  @override
  Future<FreeWaterConfig> getFreeWaterConfig(
    AccountCredential credential,
  ) async {
    configCredentialMobile = credential.mobile;
    return const FreeWaterConfig(
      id: 'config-1',
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
    detailCredentialMobile = credential.mobile;
    return const DeviceStation(
      id: 'device-1',
      name: '冯塘乡丁洼村',
      status: 'OFFLINE',
      regionCode: 'in-village',
      deviceNum: '864708065296769',
      address: '超市门口',
      isOnline: true,
      dispenserType: 'ALL_FREE',
      dispenserTypeDesc: '全部免费',
      statusDescription: '水箱水量192L',
    );
  }

  @override
  Future<List<DeviceStation>> getWaterStations({
    required String regionCode,
    required AccountCredential credential,
  }) async {
    stationCredentialMobiles.add(credential.mobile);
    if (regionCode == 'default-page') {
      return const <DeviceStation>[
        DeviceStation(
          id: 'device-2',
          name: '卫贤姜含珠',
          status: 'ONLINE',
          regionCode: 'default-page',
          deviceNum: '865096063551420',
          address: '卫贤镇姜含珠',
          isOnline: true,
          dispenserType: 'ALL_FREE',
          dispenserTypeDesc: '全部免费',
        ),
      ];
    }
    return const <DeviceStation>[
      DeviceStation(
        id: 'device-1',
        name: '冯塘乡丁洼村',
        status: 'ONLINE',
        regionCode: 'in-village',
        deviceNum: '864708065296769',
        address: '超市门口',
        isOnline: true,
        dispenserType: 'ALL_FREE',
        dispenserTypeDesc: '全部免费',
      ),
    ];
  }
}

class _QuotaFailureDeviceGateway extends _RecordingDeviceGateway {
  @override
  Future<void> dispenseWater({
    required String stationId,
    required int quantity,
    required AccountCredential credential,
  }) {
    throw StateError('超出每日取水【2】次数,请明日再试');
  }
}

class _MultiStationDeviceGateway extends _RecordingDeviceGateway {
  String? detailStationId;

  @override
  Future<void> dispenseWater({
    required String stationId,
    required int quantity,
    required AccountCredential credential,
  }) async {
    dispenseStationId = stationId;
    await super.dispenseWater(
      stationId: stationId,
      quantity: quantity,
      credential: credential,
    );
  }

  @override
  Future<DeviceStation> getStationDetail({
    required String stationId,
    required AccountCredential credential,
  }) async {
    detailStationId = stationId;
    if (stationId == 'device-2') {
      return const DeviceStation(
        id: 'device-2',
        name: '卫贤姜含珠',
        status: 'ONLINE',
        regionCode: 'in-village',
        deviceNum: '865096063551420',
        isOnline: true,
        dispenserType: 'ALL_FREE',
        dispenserTypeDesc: '全部免费',
      );
    }
    return super.getStationDetail(stationId: stationId, credential: credential);
  }

  @override
  Future<List<DeviceStation>> getWaterStations({
    required String regionCode,
    required AccountCredential credential,
  }) async {
    stationCredentialMobiles.add(credential.mobile);
    return const <DeviceStation>[
      DeviceStation(
        id: 'device-1',
        name: '冯塘乡丁洼村',
        status: 'ONLINE',
        regionCode: 'in-village',
        deviceNum: '864708065296769',
        isOnline: true,
        dispenserType: 'ALL_FREE',
        dispenserTypeDesc: '全部免费',
      ),
      DeviceStation(
        id: 'device-2',
        name: '卫贤姜含珠',
        status: 'ONLINE',
        regionCode: 'in-village',
        deviceNum: '865096063551420',
        isOnline: true,
        dispenserType: 'ALL_FREE',
        dispenserTypeDesc: '全部免费',
      ),
    ];
  }
}
