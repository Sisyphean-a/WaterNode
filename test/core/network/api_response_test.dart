import 'package:flutter_test/flutter_test.dart';
import 'package:waternode/core/errors/app_exception.dart';
import 'package:waternode/core/network/api_response.dart';

void main() {
  test('ensureSuccess allows 200 responses', () {
    expect(
      () => ApiResponse.ensureSuccess(<String, dynamic>{
        'code': '200',
        'msg': 'ok',
      }, action: 'demo'),
      returnsNormally,
    );
  });

  test('ensureSuccess throws backend message when code is not 200', () {
    expect(
      () => ApiResponse.ensureSuccess(<String, dynamic>{
        'code': '500',
        'msg': '服务异常',
      }, action: 'demo'),
      throwsA(
        isA<AppException>().having((error) => error.message, 'message', '服务异常'),
      ),
    );
  });

  test('readDataMap returns typed payload map after success validation', () {
    final data = ApiResponse.readDataMap(<String, dynamic>{
      'code': '200',
      'data': <String, dynamic>{'id': 'config-1'},
    }, action: 'demo');

    expect(data['id'], 'config-1');
  });

  test('readDataMap throws when data payload is not an object', () {
    expect(
      () => ApiResponse.readDataMap(<String, dynamic>{
        'code': '200',
        'data': 'invalid',
      }, action: 'demo'),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          'demo response data is not an object',
        ),
      ),
    );
  });
}
