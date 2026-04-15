import 'package:waternode/core/network/api_client.dart';
import 'package:waternode/core/network/dynamic_header_factory.dart';
import 'package:waternode/features/auth/domain/gateways/auth_gateway.dart';
import 'package:waternode/features/auth/domain/models/auth_session.dart';

class AuthApi implements AuthGateway {
  AuthApi(this._client, this._headerFactory);

  final ApiClient _client;
  final DynamicHeaderFactory _headerFactory;

  @override
  Future<String> sendCode(String mobile) async {
    final response = await _client.post(
      '/ids/pub/sms/sendCode',
      headers: _headerFactory.buildPreAuthHeaders(),
      body: <String, dynamic>{'mobile': mobile, 'businessType': 'LOGIN'},
    );
    return response['data']['id'] as String;
  }

  @override
  Future<AuthSession> login({
    required String mobile,
    required String smsCode,
    required String smsCodeId,
  }) async {
    final response = await _client.post(
      '/ids/pub/login/loginRegisterBySmsCode',
      headers: _headerFactory.buildPreAuthHeaders(),
      body: <String, dynamic>{
        'mobile': mobile,
        'smsCode': smsCode,
        'smsCodeId': smsCodeId,
      },
    );
    return AuthSession(
      mobile: mobile,
      token: response['data']['token'] as String,
    );
  }
}
