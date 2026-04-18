import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:waternode/app/application/console_shell_controller.dart';
import 'package:waternode/features/auth/application/auth_controller.dart';
import 'package:waternode/features/auth/domain/gateways/auth_gateway.dart';
import 'package:waternode/features/auth/domain/models/auth_session.dart';
import 'package:waternode/features/auth/infrastructure/token_payload_parser.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/domain/gateways/account_profile_gateway.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/credentials/domain/models/account_sign_in_state.dart';
import 'package:waternode/features/credentials/infrastructure/memory_account_repository.dart';
import 'package:waternode/features/credentials/presentation/pages/credential_page.dart';
import 'package:waternode/features/dashboard/application/dashboard_controller.dart';
import 'package:waternode/features/dashboard/domain/gateways/activity_gateway.dart';
import 'package:waternode/features/dashboard/domain/models/account_bill.dart';
import 'package:waternode/features/dashboard/domain/models/account_status.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    Get.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('shows import entry and in-page automation actions', (
    tester,
  ) async {
    await _pumpCredentialPage(tester, repository: MemoryAccountRepository());

    expect(find.byTooltip('批量签到'), findsOneWidget);
    expect(find.byTooltip('批量抽奖'), findsOneWidget);
    expect(find.text('添加'), findsOneWidget);
    expect(find.text('全员智能签到'), findsNothing);
    expect(find.text('自动化'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, '添加'));
    await tester.pumpAndSettle();

    expect(find.text('添加账号'), findsOneWidget);
    expect(find.text('手动登录'), findsOneWidget);
    expect(find.text('导入 Token'), findsOneWidget);

    await tester.tap(find.text('导入 Token'));
    await tester.pumpAndSettle();

    expect(find.text('粘贴 Token'), findsOneWidget);
    expect(find.byKey(const Key('import-token-input')), findsOneWidget);
  });

  testWidgets('opens add-account dialog instead of navigating to auth page', (
    tester,
  ) async {
    final repository = MemoryAccountRepository();
    await _pumpCredentialPage(
      tester,
      repository: repository,
      authGateway: _FakeAuthGateway(),
    );

    await tester.tap(find.widgetWithText(FilledButton, '添加'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('手动登录'));
    await tester.pumpAndSettle();

    expect(find.text('新增账户'), findsOneWidget);
    expect(find.text('手机号'), findsOneWidget);
    expect(find.text('验证码'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '发送'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '登录'), findsOneWidget);
    expect(find.text('登录授权'), findsNothing);
  });

  testWidgets('copies token to clipboard from credential card', (tester) async {
    String? copiedText;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copiedText =
                (call.arguments as Map<dynamic, dynamic>)['text'] as String?;
          }
          return null;
        });

    await _pumpCredentialPage(
      tester,
      repository: MemoryAccountRepository(<AccountCredential>[
        const AccountCredential(
          mobile: '15700000000',
          token: 'token-123',
          platformType: 'CUSTOMER_APP',
          deviceId: 'device-1',
          userId: 'user-1',
          points: 20,
          isValid: true,
          signInState: AccountSignInState.completed,
        ),
      ]),
    );

    await tester.tap(find.text('15700000000'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, '复制 Token'));
    await tester.pump();

    expect(copiedText, 'token-123');
  });

  testWidgets('persists remark when remark input loses focus', (tester) async {
    final repository = MemoryAccountRepository(<AccountCredential>[
      const AccountCredential(
        mobile: '15700000000',
        token: 'token-123',
        platformType: 'CUSTOMER_APP',
        deviceId: 'device-1',
        userId: 'user-1',
        points: 20,
        isValid: true,
        signInState: AccountSignInState.completed,
      ),
    ]);

    await _pumpCredentialPage(tester, repository: repository);

    await tester.tap(find.text('15700000000'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '家里');
    await tester.tap(find.widgetWithText(FilledButton, '保存修改'));
    await tester.pumpAndSettle();

    final controller = Get.find<CredentialController>();
    expect(controller.credentials.single.remark, '家里');

    final persisted = await repository.readAll();
    expect(persisted.single.remark, '家里');
  });
}

Future<void> _pumpCredentialPage(
  WidgetTester tester, {
  required MemoryAccountRepository repository,
  AuthGateway? authGateway,
}) async {
  Get.testMode = true;
  Get.put(ConsoleShellController(), permanent: true);
  final controller = CredentialController(
    repository,
    _FakeActivityGateway(),
    TokenPayloadParser(),
    _FakeAccountProfileGateway(),
  );
  await controller.load();
  Get.put(controller, permanent: true);
  Get.put(
    DashboardController(controller, _FakeActivityGateway()),
    permanent: true,
  );
  Get.put(
    AuthController(
      authGateway ?? _FakeAuthGateway(),
      repository,
      TokenPayloadParser(),
      onCredentialSaved: controller.load,
    ),
    permanent: true,
  );

  await tester.pumpWidget(
    GetMaterialApp(home: Scaffold(body: CredentialPage())),
  );
  await tester.pumpAndSettle();
}

class _FakeActivityGateway implements ActivityGateway {
  @override
  Future<AccountStatus> fetchStatus(AccountCredential credential) async {
    return AccountStatus(
      isValid: credential.isValid,
      points: credential.points,
      signInState: credential.signInState,
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

class _FakeAccountProfileGateway implements AccountProfileGateway {
  @override
  Future<String> fetchMobile(String token) async => '15700000000';
}

class _FakeAuthGateway implements AuthGateway {
  @override
  Future<AuthSession> login({
    required String mobile,
    required String smsCode,
    required String smsCodeId,
  }) async {
    return AuthSession(
      mobile: mobile,
      token:
          'eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.'
          'eyJwbGF0Zm9ybVR5cGUiOiJDVVNUT01FUl9BUF'
          'AiLCJkZXZpY2VJZCI6ImRldmljZS0xIiwidXNlcklkIjoidXNlci0xIn0.'
          'signature',
    );
  }

  @override
  Future<String> sendCode(String mobile) async => 'sms-id-1';
}
