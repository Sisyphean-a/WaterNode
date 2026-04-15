import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/core/network/api_client.dart';
import 'package:waternode/core/network/dynamic_header_factory.dart';
import 'package:waternode/features/auth/infrastructure/token_payload_parser.dart';
import 'package:waternode/features/credentials/domain/models/account_sign_in_state.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/dashboard/infrastructure/activity_api.dart';

void main() {
  late _RecordingApiClient client;
  late ActivityApi api;

  setUp(() {
    client = _RecordingApiClient();
    api = ActivityApi(client, DynamicHeaderFactory(TokenPayloadParser()));
  });

  test('fetchStatus reads actual balance from coin account endpoint', () async {
    final credential = AccountCredential(
      mobile: '15700000000',
      token: _buildToken(
        platformType: 'APPLETS',
        deviceId: 'microsoftWindows 10 x64',
        userId: 'user-coin',
      ),
      platformType: 'APPLETS',
      deviceId: 'microsoftWindows 10 x64',
      userId: 'user-coin',
      points: 0,
      isValid: true,
    );
    client.responseForGet['/pay/account/coin/user'] = <String, dynamic>{
      'code': '200',
      'msg': '用户金额查询成功',
      'data': <String, dynamic>{'totalFee': 10125.0},
      'ok': true,
    };
    client.responseForGet['/marketing/userSgin/consSignDay'] = <String, dynamic>{
      'code': '200',
      'msg': '操作成功',
      'data': 62,
      'ok': true,
    };

    final status = await api.fetchStatus(credential);

    expect(
      client.pathHistory,
      containsAll(<String>[
        '/pay/account/coin/user',
        '/marketing/userSgin/consSignDay',
      ]),
    );
    expect(
      client.queryHistory.whereType<Map<String, dynamic>>().any(
        (item) =>
            item['accountType'] == 'COIN' && item['userId'] == 'user-coin',
      ),
      isTrue,
    );
    expect(client.lastHeaders?['User-Id'], 'user-coin');
    expect(client.lastHeaders?['Platform-Type'], 'APPLETS');
    expect(client.lastHeaders?['xweb_xhr'], '1');
    expect(client.lastHeaders?['Content-Type'], 'application/json');
    expect(status.isValid, isTrue);
    expect(status.points, 10125);
    expect(status.signInState, AccountSignInState.completed);
  });

  test(
    'fetchStatus marks credential invalid when balance endpoint returns h009',
    () async {
      final credential = AccountCredential(
        mobile: '15700000000',
        token: _buildToken(
          platformType: 'CUSTOMER_APP',
          deviceId: 'device-1',
          userId: 'user-invalid',
        ),
        platformType: 'CUSTOMER_APP',
        deviceId: 'device-1',
        userId: 'user-invalid',
        points: 0,
        isValid: true,
      );
      client.responseForGet['/pay/account/coin/user'] = <String, dynamic>{
        'code': 'h009',
        'msg': '登录失效',
      };

      final status = await api.fetchStatus(credential);

      expect(status.isValid, isFalse);
      expect(status.points, 0);
      expect(status.signInState, AccountSignInState.unknown);
    },
  );

  test('fetchStatus marks account as not signed in when consSignDay is false', () async {
    final credential = AccountCredential(
      mobile: '15700000000',
      token: _buildToken(
        platformType: 'CUSTOMER_APP',
        deviceId: 'device-1',
        userId: 'user-need-sign',
      ),
      platformType: 'CUSTOMER_APP',
      deviceId: 'device-1',
      userId: 'user-need-sign',
      points: 0,
      isValid: true,
    );
    client.responseForGet['/pay/account/coin/user'] = <String, dynamic>{
      'code': '200',
      'data': <String, dynamic>{'totalFee': 1200},
      'ok': true,
    };
    client.responseForGet['/marketing/userSgin/consSignDay'] = <String, dynamic>{
      'code': '200',
      'msg': '操作成功',
      'data': 0,
      'ok': false,
    };

    final status = await api.fetchStatus(credential);

    expect(status.isValid, isTrue);
    expect(status.points, 1200);
    expect(status.signInState, AccountSignInState.available);
  });

  test('fetchBills reads recent bean bills from real endpoint', () async {
    final credential = AccountCredential(
      mobile: '15700000000',
      token: _buildToken(
        platformType: 'APPLETS',
        deviceId: 'microsoftWindows 10 x64',
        userId: 'user-bill',
      ),
      platformType: 'APPLETS',
      deviceId: 'microsoftWindows 10 x64',
      userId: 'user-bill',
      points: 0,
      isValid: true,
    );
    client.responseForGet['/pay/user/accountDetail/bean/list'] = <String, dynamic>{
      'code': '200',
      'msg': '操作成功',
      'data': <String, dynamic>{
        'content': <Map<String, dynamic>>[
          <String, dynamic>{
            'amount': 200.0,
            'inOrPay': 'OUT',
            'inOrPayDesc': '支出',
            'billType': 'SCAN_FETCH_WATER',
            'billTypeDesc': '扫码取水',
            'createTime': '2026-04-15 19:43:46',
            'remark': '扫码取水扣除小康豆',
            'totalAmount': 10125.0,
          },
          <String, dynamic>{
            'amount': 70.0,
            'inOrPay': 'IN',
            'inOrPayDesc': '收入',
            'billType': 'SIGN_IN',
            'billTypeDesc': '用户签到',
            'createTime': '2026-04-15 05:26:28',
            'remark': '签到奖励',
            'totalAmount': 10495.0,
          },
        ],
      },
      'ok': true,
    };

    final bills = await api.fetchBills(credential);

    expect(client.lastGetPath, '/pay/user/accountDetail/bean/list');
    expect(client.lastHeaders?['User-Id'], 'user-bill');
    expect(client.lastHeaders?['Page-Num'], '1');
    expect(client.lastHeaders?['Page-Size'], '10');
    expect(bills, hasLength(2));
    expect(bills.first.billType, 'SCAN_FETCH_WATER');
    expect(bills.first.totalAmount, 10125);
    expect(bills.last.billType, 'SIGN_IN');
  });
}

class _RecordingApiClient extends ApiClient {
  _RecordingApiClient() : super(Dio());

  final Map<String, Map<String, dynamic>> responseForGet =
      <String, Map<String, dynamic>>{};
  final List<String> pathHistory = <String>[];
  final List<Map<String, dynamic>?> queryHistory = <Map<String, dynamic>?>[];
  String? lastGetPath;
  Map<String, String>? lastHeaders;
  Map<String, dynamic>? lastQueryParameters;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    lastGetPath = path;
    pathHistory.add(path);
    lastHeaders = headers;
    lastQueryParameters = queryParameters;
    queryHistory.add(queryParameters);
    return responseForGet[path] ?? <String, dynamic>{'code': '200'};
  }
}

String _buildToken({
  required String platformType,
  required String deviceId,
  required String userId,
}) {
  final header = base64Url.encode(utf8.encode('{"alg":"none","typ":"JWT"}'));
  final payload = base64Url.encode(
    utf8.encode(
      jsonEncode(<String, String>{
        'platformType': platformType,
        'deviceId': deviceId,
        'userId': userId,
      }),
    ),
  );

  return '$header.$payload.signature';
}
