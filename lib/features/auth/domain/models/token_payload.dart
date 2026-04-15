class TokenPayload {
  const TokenPayload({
    required this.platformType,
    required this.deviceId,
    required this.userId,
  });

  final String platformType;
  final String deviceId;
  final String userId;
}
