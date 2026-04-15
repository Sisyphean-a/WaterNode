import 'package:waternode/features/credentials/domain/models/account_sign_in_state.dart';

class AccountCredential {
  const AccountCredential({
    required this.mobile,
    required this.token,
    required this.platformType,
    required this.deviceId,
    required this.userId,
    required this.points,
    required this.isValid,
    this.remark,
    this.defaultRegionCode,
    this.signInState = AccountSignInState.unknown,
    this.lastCheckedAt,
  });

  final String mobile;
  final String token;
  final String platformType;
  final String deviceId;
  final String userId;
  final int points;
  final bool isValid;
  final String? remark;
  final String? defaultRegionCode;
  final AccountSignInState signInState;
  final DateTime? lastCheckedAt;

  AccountCredential copyWith({
    String? mobile,
    String? token,
    String? platformType,
    String? deviceId,
    String? userId,
    int? points,
    bool? isValid,
    String? remark,
    String? defaultRegionCode,
    AccountSignInState? signInState,
    DateTime? lastCheckedAt,
  }) {
    return AccountCredential(
      mobile: mobile ?? this.mobile,
      token: token ?? this.token,
      platformType: platformType ?? this.platformType,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      points: points ?? this.points,
      isValid: isValid ?? this.isValid,
      remark: remark ?? this.remark,
      defaultRegionCode: defaultRegionCode ?? this.defaultRegionCode,
      signInState: signInState ?? this.signInState,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'mobile': mobile,
      'token': token,
      'platformType': platformType,
      'deviceId': deviceId,
      'userId': userId,
      'points': points,
      'isValid': isValid,
      'remark': remark,
      'defaultRegionCode': defaultRegionCode,
      'signInState': signInState.name,
      'lastCheckedAt': lastCheckedAt?.toIso8601String(),
    };
  }

  factory AccountCredential.fromMap(Map<dynamic, dynamic> map) {
    return AccountCredential(
      mobile: map['mobile'] as String,
      token: map['token'] as String,
      platformType: map['platformType'] as String,
      deviceId: map['deviceId'] as String,
      userId: map['userId'] as String,
      points: map['points'] as int? ?? 0,
      isValid: map['isValid'] as bool? ?? false,
      remark: map['remark'] as String?,
      defaultRegionCode: map['defaultRegionCode'] as String?,
      signInState: parseSignInState(map['signInState']),
      lastCheckedAt: parseDateTime(map['lastCheckedAt']),
    );
  }

  static DateTime? parseDateTime(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value);
    }
    return null;
  }

  static AccountSignInState parseSignInState(dynamic value) {
    if (value is String) {
      return AccountSignInState.values.firstWhere(
        (item) => item.name == value,
        orElse: () => AccountSignInState.unknown,
      );
    }
    return AccountSignInState.unknown;
  }
}
