import 'package:waternode/core/network/api_client.dart';
import 'package:waternode/core/network/api_endpoints.dart';
import 'package:waternode/core/network/api_response.dart';
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
      ApiEndpoints.authSendCode,
      headers: _headerFactory.buildPreAuthHeaders(),
      body: <String, dynamic>{'mobile': mobile, 'businessType': 'LOGIN'},
    );
    final data = ApiResponse.readDataMap(response, action: 'sendCode');
    return data['id'] as String;
  }

  @override
  Future<AuthSession> login({
    required String mobile,
    required String smsCode,
    required String smsCodeId,
  }) async {
    final response = await _client.post(
      ApiEndpoints.authLoginBySmsCode,
      headers: _headerFactory.buildPreAuthHeaders(),
      body: <String, dynamic>{
        'mobile': mobile,
        'smsCode': smsCode,
        'smsCodeId': smsCodeId,
      },
    );
    final data = ApiResponse.readDataMap(response, action: 'loginBySmsCode');
    return AuthSession(mobile: mobile, token: data['token'] as String);
  }
}
