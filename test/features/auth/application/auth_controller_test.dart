import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/features/auth/application/auth_controller.dart';
import 'package:waternode/features/auth/domain/gateways/auth_gateway.dart';
import 'package:waternode/features/auth/domain/models/auth_session.dart';
import 'package:waternode/features/auth/infrastructure/token_payload_parser.dart';
import 'package:waternode/features/credentials/infrastructure/memory_account_repository.dart';

void main() {
  test('saves credential after successful login', () async {
    final repository = MemoryAccountRepository();
    final controller = AuthController(
      _FakeAuthGateway(),
      repository,
      TokenPayloadParser(),
    );

    await controller.sendCode('15700000000');
    await controller.login(mobile: '15700000000', smsCode: '123456');

    final credentials = await repository.readAll();
    expect(credentials, hasLength(1));
    expect(credentials.single.mobile, '15700000000');
    expect(credentials.single.platformType, 'CUSTOMER_APP');
  });
}

class _FakeAuthGateway implements AuthGateway {
  @override
  Future<AuthSession> login({
    required String mobile,
    required String smsCode,
    required String smsCodeId,
  }) async {
    return AuthSession(mobile: mobile, token: _buildToken());
  }

  @override
  Future<String> sendCode(String mobile) async => 'sms-id-1';

  String _buildToken() {
    final header = base64Url.encode(utf8.encode('{"alg":"none","typ":"JWT"}'));
    final payload = base64Url.encode(
      utf8.encode(
        '{"platformType":"CUSTOMER_APP","deviceId":"device-1","userId":"user-1"}',
      ),
    );
    return '$header.$payload.signature';
  }
}
