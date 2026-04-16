import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:waternode/app/application/console_shell_controller.dart';
import 'package:waternode/features/auth/infrastructure/token_payload_parser.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/credentials/domain/gateways/account_profile_gateway.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/credentials/domain/models/account_sign_in_state.dart';
import 'package:waternode/features/credentials/infrastructure/memory_account_repository.dart';
import 'package:waternode/features/credentials/presentation/pages/credential_page.dart';
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

  testWidgets('shows token import entry on credential page', (tester) async {
    await _pumpCredentialPage(
      tester,
      repository: MemoryAccountRepository(),
    );

    expect(find.widgetWithText(FilledButton, '导入 Token'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '导入 Token'));
    await tester.pumpAndSettle();

    expect(find.text('粘贴 Token'), findsOneWidget);
    expect(find.byKey(const Key('import-token-input')), findsOneWidget);
  });

  testWidgets('copies token to clipboard from credential card', (tester) async {
    String? copiedText;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copiedText = (call.arguments as Map<dynamic, dynamic>)['text']
                as String?;
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

    await tester.tap(find.byKey(const Key('copy-token-15700000000')));
    await tester.pump();

    expect(copiedText, 'token-123');
  });
}

Future<void> _pumpCredentialPage(
  WidgetTester tester, {
  required MemoryAccountRepository repository,
}) async {
  Get.testMode = true;
  Get.put(ConsoleShellController(), permanent: true);
  final controller = CredentialController(
    repository,
    _FakeActivityGateway(),
    TokenPayloadParser(),
    _FakeAccountProfileGateway(),
  );
  Get.put(controller, permanent: true);

  await tester.pumpWidget(
    GetMaterialApp(
      home: Scaffold(body: CredentialPage()),
    ),
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
