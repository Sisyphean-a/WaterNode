import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/credentials/infrastructure/memory_account_repository.dart';
import 'package:waternode/features/dashboard/domain/gateways/activity_gateway.dart';
import 'package:waternode/features/dashboard/domain/models/account_status.dart';
import 'package:waternode/features/devices/application/device_controller.dart';
import 'package:waternode/features/devices/domain/gateways/device_gateway.dart';
import 'package:waternode/features/devices/domain/models/device_station.dart';
import 'package:waternode/features/devices/domain/models/free_water_config.dart';

void main() {
  test(
    'loads free water config and real stations with first valid account',
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

      await controller.loadStations();

      expect(controller.freeWaterConfig.value?.waterVolume, 7.5);
      expect(controller.stations, hasLength(1));
      expect(controller.stations.single.name, '冯塘乡丁洼村');
      expect(gateway.configCredentialMobile, '15700000000');
      expect(gateway.stationCredentialMobile, '15700000000');
      expect(controller.lastError.value, isNull);
    },
  );

  test(
    'dispatches water with points-positive account and records success log',
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
      await controller.loadStations();

      await controller.sendCommand(controller.stations.single);

      expect(gateway.detailCredentialMobile, '15800000000');
      expect(gateway.dispenseCredentialMobile, '15800000000');
      expect(gateway.lastDispenseQuantity, 1);
      expect(controller.logs.first, contains('15800000000'));
      expect(controller.logs.first, contains('7.5L'));
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

      await expectLater(controller.loadStations, throwsA(isA<StateError>()));
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
    );
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
  String? stationCredentialMobile;
  String? detailCredentialMobile;
  String? dispenseCredentialMobile;
  int? lastDispenseQuantity;

  @override
  Future<void> dispenseWater({
    required String stationId,
    required int quantity,
    required AccountCredential credential,
  }) async {
    dispenseCredentialMobile = credential.mobile;
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
    stationCredentialMobile = credential.mobile;
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
