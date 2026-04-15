import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/features/credentials/domain/models/account_sign_in_state.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/dashboard/domain/models/account_bill.dart';
import 'package:waternode/features/credentials/infrastructure/memory_account_repository.dart';
import 'package:waternode/features/dashboard/domain/gateways/activity_gateway.dart';
import 'package:waternode/features/dashboard/domain/models/account_status.dart';

void main() {
  test('loads and refreshes credential status on init', () async {
    final repository = MemoryAccountRepository();
    await repository.save(
      const AccountCredential(
        mobile: '15700000000',
        token: 'token',
        platformType: 'CUSTOMER_APP',
        deviceId: 'device-1',
        userId: 'user-1',
        points: 0,
        isValid: true,
      ),
    );
    final controller = CredentialController(repository, _FakeActivityGateway());

    controller.onInit();
    await Future<void>.delayed(Duration.zero);

    expect(controller.credentials.single.points, 88);
    expect(controller.credentials.single.isValid, true);
    expect(
      controller.credentials.single.signInState,
      AccountSignInState.completed,
    );
  });

  test('refreshes credential status and points', () async {
    final repository = MemoryAccountRepository();
    await repository.save(
      const AccountCredential(
        mobile: '15700000000',
        token: 'token',
        platformType: 'CUSTOMER_APP',
        deviceId: 'device-1',
        userId: 'user-1',
        points: 0,
        isValid: true,
      ),
    );
    final controller = CredentialController(repository, _FakeActivityGateway());

    await controller.refreshStatuses();

    expect(controller.credentials.single.points, 88);
    expect(controller.credentials.single.isValid, true);
    expect(
      controller.credentials.single.signInState,
      AccountSignInState.completed,
    );
  });

  test('updates account remark and default region persistently', () async {
    final repository = MemoryAccountRepository();
    await repository.save(
      const AccountCredential(
        mobile: '15700000000',
        token: 'token',
        platformType: 'CUSTOMER_APP',
        deviceId: 'device-1',
        userId: 'user-1',
        points: 0,
        isValid: true,
      ),
    );
    final controller = CredentialController(repository, _FakeActivityGateway());

    await controller.load();
    await controller.updateAccountMeta(
      controller.credentials.single,
      remark: '家里',
      defaultRegionCode: 'default-page',
    );

    expect(controller.credentials.single.remark, '家里');
    expect(controller.credentials.single.defaultRegionCode, 'default-page');

    final persisted = await repository.readAll();
    expect(persisted.single.remark, '家里');
    expect(persisted.single.defaultRegionCode, 'default-page');
  });
}

class _FakeActivityGateway implements ActivityGateway {
  @override
  Future<AccountStatus> fetchStatus(AccountCredential credential) async {
    return const AccountStatus(
      isValid: true,
      points: 88,
      signInState: AccountSignInState.completed,
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
