import 'package:waternode/features/auth/domain/models/auth_session.dart';

abstract interface class AuthGateway {
  Future<String> sendCode(String mobile);

  Future<AuthSession> login({
    required String mobile,
    required String smsCode,
    required String smsCodeId,
  });
}
