import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/features/credentials/domain/models/account_sign_in_state.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/credentials/infrastructure/memory_account_repository.dart';
import 'package:waternode/features/dashboard/application/dashboard_controller.dart';
import 'package:waternode/features/dashboard/domain/gateways/activity_gateway.dart';
import 'package:waternode/features/dashboard/domain/models/account_bill.dart';
import 'package:waternode/features/dashboard/domain/models/account_status.dart';

void main() {
  test('runs sign-in only for valid accounts and records logs', () async {
    final repository = MemoryAccountRepository();
    await repository.save(
      const AccountCredential(
        mobile: '15700000000',
        token: 'token-1',
        platformType: 'CUSTOMER_APP',
        deviceId: 'device-1',
        userId: 'user-1',
        points: 2,
        isValid: true,
      ),
    );
    await repository.save(
      const AccountCredential(
        mobile: '15800000000',
        token: 'token-2',
        platformType: 'CUSTOMER_APP',
        deviceId: 'device-2',
        userId: 'user-2',
        points: 0,
        isValid: false,
      ),
    );
    final credentialController = CredentialController(
      repository,
      _DashboardGateway(),
    );
    await credentialController.load();
    final controller = DashboardController(
      credentialController,
      _DashboardGateway(),
    );

    await controller.runBatchSignIn();

    expect(controller.logs, hasLength(1));
    expect(controller.logs.single.message, contains('签到成功'));
  });

  test('skips already-signed accounts during batch sign-in', () async {
    final repository = MemoryAccountRepository();
    await repository.save(
      const AccountCredential(
        mobile: '15700000000',
        token: 'token-1',
        platformType: 'CUSTOMER_APP',
        deviceId: 'device-1',
        userId: 'user-1',
        points: 0,
        isValid: true,
      ),
    );
    final gateway = _AlreadySignedDashboardGateway();
    final credentialController = CredentialController(repository, gateway);
    await credentialController.load();
    final controller = DashboardController(credentialController, gateway);

    await controller.runBatchSignIn();

    expect(gateway.signInCalls, 0);
    expect(gateway.fetchStatusCalls, 1);
    expect(controller.logs.single.message, contains('今日已签到'));
    expect(controller.logs.single.message, contains('跳过'));
  });

  test('refreshes statuses again after batch sign-in', () async {
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
    final gateway = _RefreshingDashboardGateway();
    final credentialController = CredentialController(repository, gateway);
    await credentialController.load();
    final controller = DashboardController(credentialController, gateway);

    await controller.runBatchSignIn();

    expect(gateway.signInCalls, 1);
    expect(gateway.fetchStatusCalls, 2);
    expect(controller.logs.single.message, contains('签到成功'));
    expect(controller.totalPoints, 18);
    expect(
      credentialController.credentials.single.signInState,
      AccountSignInState.completed,
    );
  });
}

class _DashboardGateway implements ActivityGateway {
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

class _RefreshingDashboardGateway implements ActivityGateway {
  int fetchStatusCalls = 0;
  int signInCalls = 0;

  @override
  Future<AccountStatus> fetchStatus(AccountCredential credential) async {
    fetchStatusCalls++;
    if (signInCalls == 0) {
      return const AccountStatus(
        isValid: true,
        points: 12,
        signInState: AccountSignInState.available,
      );
    }
    return const AccountStatus(
      isValid: true,
      points: 18,
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
  Future<void> signIn(AccountCredential credential) async {
    signInCalls++;
  }
}

class _AlreadySignedDashboardGateway implements ActivityGateway {
  int fetchStatusCalls = 0;
  int signInCalls = 0;

  @override
  Future<AccountStatus> fetchStatus(AccountCredential credential) async {
    fetchStatusCalls++;
    return const AccountStatus(
      isValid: true,
      points: 12,
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
  Future<void> signIn(AccountCredential credential) async {
    signInCalls++;
  }
}
