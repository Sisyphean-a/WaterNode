import 'package:waternode/core/errors/app_exception.dart';

abstract final class ApiResponse {
  static const successCode = '200';

  static String? readCode(Map<String, dynamic> response) {
    return response['code']?.toString();
  }

  static void ensureSuccess(
    Map<String, dynamic> response, {
    required String action,
  }) {
    final code = readCode(response);
    if (code == successCode) {
      return;
    }

    final message = response['msg'] as String?;
    if (message != null && message.isNotEmpty) {
      throw AppException(message);
    }
    throw AppException('$action returned unexpected code: $code');
  }

  static Map<String, dynamic> readDataMap(
    Map<String, dynamic> response, {
    required String action,
  }) {
    ensureSuccess(response, action: action);
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw AppException('$action response data is not an object');
  }
}
