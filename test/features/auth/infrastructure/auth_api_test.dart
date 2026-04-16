import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/core/errors/app_exception.dart';
import 'package:waternode/core/network/api_client.dart';
import 'package:waternode/core/network/api_endpoints.dart';
import 'package:waternode/core/network/dynamic_header_factory.dart';
import 'package:waternode/features/auth/infrastructure/auth_api.dart';
import 'package:waternode/features/auth/infrastructure/token_payload_parser.dart';

void main() {
  late _RecordingApiClient client;
  late AuthApi api;

  setUp(() {
    client = _RecordingApiClient();
    api = AuthApi(client, DynamicHeaderFactory(TokenPayloadParser()));
  });

  test('sendCode reads sms code id from response data', () async {
    client.responseForPost[ApiEndpoints.authSendCode] = <String, dynamic>{
      'code': '200',
      'data': <String, dynamic>{'id': 'sms-code-id'},
    };

    final codeId = await api.sendCode('15700000000');

    expect(codeId, 'sms-code-id');
    expect(client.lastPostPath, ApiEndpoints.authSendCode);
    expect(client.lastBody?['businessType'], 'LOGIN');
  });

  test('login reads token from response data', () async {
    client.responseForPost[ApiEndpoints.authLoginBySmsCode] = <String, dynamic>{
      'code': '200',
      'data': <String, dynamic>{'token': 'token-1'},
    };

    final session = await api.login(
      mobile: '15700000000',
      smsCode: '123456',
      smsCodeId: 'sms-id',
    );

    expect(session.mobile, '15700000000');
    expect(session.token, 'token-1');
    expect(client.lastPostPath, ApiEndpoints.authLoginBySmsCode);
    expect(client.lastBody?['smsCodeId'], 'sms-id');
  });

  test(
    'sendCode throws backend message when response code is not 200',
    () async {
      client.responseForPost[ApiEndpoints.authSendCode] = <String, dynamic>{
        'code': '500',
        'msg': '短信发送失败',
      };

      await expectLater(
        () => api.sendCode('15700000000'),
        throwsA(
          isA<AppException>().having(
            (error) => error.message,
            'message',
            '短信发送失败',
          ),
        ),
      );
    },
  );
}

class _RecordingApiClient extends ApiClient {
  _RecordingApiClient() : super(Dio());

  final Map<String, Map<String, dynamic>> responseForPost =
      <String, Map<String, dynamic>>{};
  String? lastPostPath;
  Map<String, String>? lastHeaders;
  Map<String, dynamic>? lastBody;

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    lastPostPath = path;
    lastHeaders = headers;
    lastBody = body;
    return responseForPost[path] ?? <String, dynamic>{'code': '200'};
  }
}
