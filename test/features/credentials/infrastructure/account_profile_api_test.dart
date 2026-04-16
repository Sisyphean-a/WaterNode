import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/core/errors/app_exception.dart';
import 'package:waternode/core/network/api_client.dart';
import 'package:waternode/core/network/dynamic_header_factory.dart';
import 'package:waternode/features/auth/infrastructure/token_payload_parser.dart';
import 'package:waternode/features/credentials/infrastructure/account_profile_api.dart';

void main() {
  late _RecordingApiClient client;
  late AccountProfileApi api;

  setUp(() {
    client = _RecordingApiClient();
    api = AccountProfileApi(client, DynamicHeaderFactory(TokenPayloadParser()));
  });

  test('fetchMobile reads mobile from findUserInfo payload', () async {
    client.responseForGet['/ids/app/user/findUserInfo'] = <String, dynamic>{
      'code': '200',
      'data': <String, dynamic>{'mobile': '15700000000'},
      'ok': true,
    };

    final mobile = await api.fetchMobile(_buildToken());

    expect(mobile, '15700000000');
    expect(client.lastGetPath, '/ids/app/user/findUserInfo');
    expect(client.lastHeaders?['Platform-Type'], 'CUSTOMER_APP');
    expect(client.lastHeaders?['Device-Id'], 'device-1');
    expect(client.lastHeaders?['Token'], isNotEmpty);
  });

  test('fetchMobile throws when findUserInfo returns non-200 code', () async {
    client.responseForGet['/ids/app/user/findUserInfo'] = <String, dynamic>{
      'code': 'h009',
      'msg': '登录失效',
      'ok': false,
    };

    await expectLater(
      () => api.fetchMobile(_buildToken()),
      throwsA(
        isA<AppException>().having((error) => error.message, 'message', '登录失效'),
      ),
    );
  });
}

class _RecordingApiClient extends ApiClient {
  _RecordingApiClient() : super(Dio());

  final Map<String, Map<String, dynamic>> responseForGet =
      <String, Map<String, dynamic>>{};
  String? lastGetPath;
  Map<String, String>? lastHeaders;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    lastGetPath = path;
    lastHeaders = headers;
    return responseForGet[path] ?? <String, dynamic>{'code': '200'};
  }
}

String _buildToken() {
  final header = base64Url.encode(utf8.encode('{"alg":"none","typ":"JWT"}'));
  final payload = base64Url.encode(
    utf8.encode(
      jsonEncode(<String, String>{
        'platformType': 'CUSTOMER_APP',
        'deviceId': 'device-1',
        'userId': 'user-1',
      }),
    ),
  );

  return '$header.$payload.signature';
}
