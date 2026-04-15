import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:waternode/features/auth/domain/models/token_payload.dart';

class TokenPayloadParser {
  TokenPayload parse(String token) {
    final payload = JwtDecoder.decode(token);

    return TokenPayload(
      platformType: readRequiredString(payload, 'platformType'),
      deviceId: readRequiredString(payload, 'deviceId'),
      userId: readRequiredString(payload, 'userId'),
    );
  }

  String readRequiredString(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }

    throw FormatException('Token payload missing required field: $key');
  }
}
