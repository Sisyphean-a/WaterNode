import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/core/network/api_client.dart';
import 'package:waternode/core/network/dynamic_header_factory.dart';
import 'package:waternode/features/auth/infrastructure/token_payload_parser.dart';
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

    final status = await api.fetchStatus(credential);

    expect(client.lastGetPath, '/pay/account/coin/user');
    expect(client.lastQueryParameters, <String, dynamic>{
      'accountType': 'COIN',
      'userId': 'user-coin',
    });
    expect(client.lastHeaders?['User-Id'], 'user-coin');
    expect(client.lastHeaders?['Platform-Type'], 'APPLETS');
    expect(client.lastHeaders?['xweb_xhr'], '1');
    expect(client.lastHeaders?['Content-Type'], 'application/json');
    expect(status.isValid, isTrue);
    expect(status.points, 10125);
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
    },
  );
}

class _RecordingApiClient extends ApiClient {
  _RecordingApiClient() : super(Dio());

  final Map<String, Map<String, dynamic>> responseForGet =
      <String, Map<String, dynamic>>{};
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
    lastHeaders = headers;
    lastQueryParameters = queryParameters;
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
