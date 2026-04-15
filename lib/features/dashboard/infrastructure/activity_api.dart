import 'package:waternode/core/errors/app_exception.dart';
import 'package:waternode/core/network/api_client.dart';
import 'package:waternode/core/network/dynamic_header_factory.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/dashboard/domain/gateways/activity_gateway.dart';
import 'package:waternode/features/dashboard/domain/models/account_status.dart';

class ActivityApi implements ActivityGateway {
  ActivityApi(this._client, this._headerFactory);

  final ApiClient _client;
  final DynamicHeaderFactory _headerFactory;

  @override
  Future<AccountStatus> fetchStatus(AccountCredential credential) async {
    final response = await _client.get(
      '/pay/account/coin/user',
      headers: _buildBalanceHeaders(credential),
      queryParameters: <String, dynamic>{
        'accountType': 'COIN',
        'userId': credential.userId,
      },
    );
    final code = response['code'] as String?;
    if (code == 'h009') {
      return const AccountStatus(isValid: false, points: 0);
    }
    if (code != '200') {
      throw AppException('coin/user returned unexpected code: $code');
    }
    final data =
        response['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return AccountStatus(isValid: true, points: _readBalance(data));
  }

  @override
  Future<void> signIn(AccountCredential credential) async {
    final response = await _client.get(
      '/marketing/userSgin/signInClick',
      headers: _headerFactory.buildAuthorizedHeaders(
        token: credential.token,
        includeUserId: true,
      ),
    );
    _ensureSuccess(response, 'signInClick');
  }

  @override
  Future<void> luckDraw(
    AccountCredential credential, {
    required String townCode,
  }) async {
    final response = await _client.get(
      '/marketing/app/turntable/luckDraw',
      headers: _headerFactory.buildAuthorizedHeaders(
        token: credential.token,
        includeUserId: true,
      ),
      queryParameters: <String, dynamic>{'townCode': townCode},
    );
    _ensureSuccess(response, 'luckDraw');
  }

  Map<String, String> _buildBalanceHeaders(AccountCredential credential) {
    final headers = _headerFactory.buildAuthorizedHeaders(
      token: credential.token,
      includeUserId: true,
    );
    if (credential.platformType == 'APPLETS') {
      return <String, String>{
        ...headers,
        'xweb_xhr': '1',
        'Content-Type': 'application/json',
      };
    }
    return headers;
  }

  int _readBalance(Map<String, dynamic> data) {
    final value = data['totalFee'];
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String && value.isNotEmpty) {
      return double.parse(value).toInt();
    }
    throw const AppException('Unable to read totalFee from coin/user payload');
  }

  void _ensureSuccess(Map<String, dynamic> response, String action) {
    final code = response['code'] as String?;
    if (code != '200') {
      throw AppException('$action returned unexpected code: $code');
    }
  }
}
