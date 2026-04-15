import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/credentials/infrastructure/memory_account_repository.dart';
import 'package:waternode/features/dashboard/domain/gateways/activity_gateway.dart';
import 'package:waternode/features/dashboard/domain/models/account_status.dart';
import 'package:waternode/features/devices/application/device_controller.dart';
import 'package:waternode/features/devices/domain/gateways/device_gateway.dart';
import 'package:waternode/features/devices/domain/models/device_station.dart';

void main() {
  test(
    'logs explicit failure when device command is not implemented',
    () async {
      final repository = MemoryAccountRepository();
      await repository.save(
        const AccountCredential(
          mobile: '15700000000',
          token: 'token-1',
          platformType: 'CUSTOMER_APP',
          deviceId: 'device-1',
          userId: 'user-1',
          points: 3,
          isValid: true,
        ),
      );
      final credentialController = CredentialController(
        repository,
        _IdleActivityGateway(),
      );
      await credentialController.load();
      final controller = DeviceController(
        credentialController,
        _UnimplementedDeviceGateway(),
      );
      controller.onInit();

      await expectLater(
        () => controller.sendCommand(controller.stations.first),
        throwsA(isA<UnimplementedError>()),
      );
      expect(controller.logs.single, contains('指令下发失败'));
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

class _UnimplementedDeviceGateway implements DeviceGateway {
  @override
  Future<void> dispenseWater({
    required String stationId,
    required int volume,
    required AccountCredential credential,
  }) {
    throw UnimplementedError('dispenseWater 接口未接入');
  }

  @override
  Future<List<DeviceStation>> getWaterStations(String regionCode) async {
    throw UnimplementedError('getWaterStations 接口未接入');
  }
}
