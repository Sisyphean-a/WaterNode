import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/core/network/dynamic_header_factory.dart';
import 'package:waternode/features/auth/infrastructure/token_payload_parser.dart';

void main() {
  late DynamicHeaderFactory factory;

  setUp(() {
    factory = DynamicHeaderFactory(TokenPayloadParser());
  });

  test('builds customer app headers from token payload', () {
    final token = buildToken(
      platformType: 'CUSTOMER_APP',
      deviceId: 'android-device',
      userId: 'user-1',
    );

    final headers = factory.buildAuthorizedHeaders(token: token);

    expect(headers['Platform-Type'], 'CUSTOMER_APP');
    expect(headers['Device-Id'], 'android-device');
    expect(headers['Token'], token);
    expect(headers['User-Agent'], 'Dart/3.11 (dart:io)');
  });

  test('builds applets headers and user id when requested', () {
    final token = buildToken(
      platformType: 'APPLETS',
      deviceId: 'mini-device',
      userId: 'user-2',
    );

    final headers = factory.buildAuthorizedHeaders(
      token: token,
      includeUserId: true,
    );

    expect(headers['Platform-Type'], 'APPLETS');
    expect(headers['Device-Id'], 'mini-device');
    expect(headers['User-Id'], 'user-2');
    expect(
      headers['User-Agent'],
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 '
      'MicroMessenger/7.0.20.1781 WindowsWechat',
    );
  });

  test('throws when token payload contains unsupported platform type', () {
    final token = buildToken(
      platformType: 'UNKNOWN',
      deviceId: 'device-x',
      userId: 'user-3',
    );

    expect(
      () => factory.buildAuthorizedHeaders(token: token),
      throwsA(isA<UnsupportedError>()),
    );
  });
}

String buildToken({
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
