import 'package:waternode/core/errors/app_exception.dart';
import 'package:waternode/core/network/api_client.dart';
import 'package:waternode/core/network/api_endpoints.dart';
import 'package:waternode/core/network/api_response.dart';
import 'package:waternode/core/network/dynamic_header_factory.dart';
import 'package:waternode/features/credentials/domain/models/account_sign_in_state.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/dashboard/domain/gateways/activity_gateway.dart';
import 'package:waternode/features/dashboard/domain/models/account_bill.dart';
import 'package:waternode/features/dashboard/domain/models/account_status.dart';

class ActivityApi implements ActivityGateway {
  ActivityApi(this._client, this._headerFactory);

  static const _billPageNum = '0';
  static const _billPageSize = '10';

  final ApiClient _client;
  final DynamicHeaderFactory _headerFactory;

  @override
  Future<AccountStatus> fetchStatus(AccountCredential credential) async {
    final response = await _client.get(
      ApiEndpoints.accountBalance,
      headers: _buildBalanceHeaders(credential),
      queryParameters: <String, dynamic>{
        'accountType': 'COIN',
        'userId': credential.userId,
      },
    );
    final code = ApiResponse.readCode(response);
    if (code == 'h009') {
      return const AccountStatus(isValid: false, points: 0);
    }
    ApiResponse.ensureSuccess(response, action: 'coin/user');
    final signInState = await _fetchSignInState(credential);
    final data = ApiResponse.readDataMap(response, action: 'coin/user');
    return AccountStatus(
      isValid: true,
      points: _readBalance(data),
      signInState: signInState,
    );
  }

  @override
  Future<List<AccountBill>> fetchBills(AccountCredential credential) async {
    final response = await _client.get(
      ApiEndpoints.accountBillList,
      headers: _buildBillHeaders(credential),
    );
    final data = ApiResponse.readDataMap(response, action: 'bean/list');
    final content = data['content'];
    if (content is! List) {
      throw const AppException('bean/list payload missing content');
    }

    return content
        .whereType<Map<String, dynamic>>()
        .map(_mapBill)
        .toList(growable: false);
  }

  @override
  Future<void> signIn(AccountCredential credential) async {
    final response = await _client.get(
      ApiEndpoints.accountSignIn,
      headers: _headerFactory.buildAuthorizedHeaders(
        token: credential.token,
        includeUserId: true,
      ),
    );
    ApiResponse.ensureSuccess(response, action: 'signInClick');
  }

  @override
  Future<void> luckDraw(
    AccountCredential credential, {
    required String townCode,
  }) async {
    final response = await _client.get(
      ApiEndpoints.accountLuckDraw,
      headers: _headerFactory.buildAuthorizedHeaders(
        token: credential.token,
        includeUserId: true,
      ),
      queryParameters: <String, dynamic>{'townCode': townCode},
    );
    ApiResponse.ensureSuccess(response, action: 'luckDraw');
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

  Map<String, String> _buildBillHeaders(AccountCredential credential) {
    final headers = _buildBalanceHeaders(credential);
    return <String, String>{
      ...headers,
      'Page-Num': _billPageNum,
      'Page-Size': _billPageSize,
    };
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

  AccountBill _mapBill(Map<String, dynamic> data) {
    return AccountBill(
      amount: _readBalance(<String, dynamic>{'totalFee': data['amount']}),
      direction: data['inOrPay']?.toString() ?? '',
      directionLabel: data['inOrPayDesc']?.toString() ?? '',
      billType: data['billType']?.toString() ?? '',
      billTypeLabel: data['billTypeDesc']?.toString() ?? '',
      createdAt: DateTime.parse(data['createTime'] as String),
      totalAmount: _readBalance(<String, dynamic>{
        'totalFee': data['totalAmount'],
      }),
      remark: data['remark']?.toString(),
    );
  }

  Future<AccountSignInState> _fetchSignInState(
    AccountCredential credential,
  ) async {
    final response = await _client.get(
      ApiEndpoints.accountSignInState,
      headers: _buildBalanceHeaders(credential),
    );
    if (ApiResponse.readCode(response) != ApiResponse.successCode) {
      return AccountSignInState.unknown;
    }
    return response['ok'] == true
        ? AccountSignInState.completed
        : AccountSignInState.available;
  }
}
