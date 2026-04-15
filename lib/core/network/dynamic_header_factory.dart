import 'package:waternode/core/constants/header_constants.dart';
import 'package:waternode/features/auth/domain/models/token_payload.dart';
import 'package:waternode/features/auth/infrastructure/token_payload_parser.dart';

class DynamicHeaderFactory {
  const DynamicHeaderFactory(this._parser);

  final TokenPayloadParser _parser;

  Map<String, String> buildPreAuthHeaders() {
    return const <String, String>{
      'platform-type': HeaderConstants.preAuthPlatformType,
      'device-id': HeaderConstants.preAuthDeviceId,
      'application-id': HeaderConstants.preAuthApplicationId,
    };
  }

  Map<String, String> buildAuthorizedHeaders({
    required String token,
    bool includeUserId = false,
  }) {
    final payload = _parser.parse(token);
    final headers = <String, String>{
      'User-Agent': resolveUserAgent(payload),
      'Platform-Type': payload.platformType,
      'Device-Id': payload.deviceId,
      'Token': token,
    };
    if (includeUserId) {
      headers['User-Id'] = payload.userId;
    }
    return headers;
  }

  String resolveUserAgent(TokenPayload payload) {
    switch (payload.platformType) {
      case 'CUSTOMER_APP':
        return HeaderConstants.customerUserAgent;
      case 'APPLETS':
        return HeaderConstants.appletsUserAgent;
      default:
        throw UnsupportedError(
          'Unsupported platform type: ${payload.platformType}',
        );
    }
  }
}
