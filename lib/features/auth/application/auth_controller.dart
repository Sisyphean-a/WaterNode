import 'package:get/get.dart';
import 'package:waternode/features/auth/domain/gateways/auth_gateway.dart';
import 'package:waternode/features/auth/infrastructure/token_payload_parser.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/credentials/domain/repositories/account_repository.dart';

class AuthController extends GetxController {
  AuthController(
    this._authGateway,
    this._repository,
    this._parser, {
    this.onCredentialSaved,
  });

  final AuthGateway _authGateway;
  final AccountRepository _repository;
  final TokenPayloadParser _parser;
  final Future<void> Function()? onCredentialSaved;

  final isSendingCode = false.obs;
  final isLoggingIn = false.obs;
  final smsCodeId = ''.obs;
  final lastError = RxnString();

  Future<void> sendCode(String mobile) async {
    isSendingCode.value = true;
    lastError.value = null;
    try {
      smsCodeId.value = await _authGateway.sendCode(mobile);
    } catch (error) {
      lastError.value = error.toString();
      rethrow;
    } finally {
      isSendingCode.value = false;
    }
  }

  Future<void> login({required String mobile, required String smsCode}) async {
    if (smsCodeId.value.isEmpty) {
      throw StateError('请先获取验证码');
    }

    isLoggingIn.value = true;
    lastError.value = null;
    try {
      final session = await _authGateway.login(
        mobile: mobile,
        smsCode: smsCode,
        smsCodeId: smsCodeId.value,
      );
      final payload = _parser.parse(session.token);
      await _repository.save(
        AccountCredential(
          mobile: session.mobile,
          token: session.token,
          platformType: payload.platformType,
          deviceId: payload.deviceId,
          userId: payload.userId,
          points: 0,
          isValid: true,
          lastCheckedAt: DateTime.now(),
        ),
      );
      if (onCredentialSaved != null) {
        await onCredentialSaved!.call();
      }
    } catch (error) {
      lastError.value = error.toString();
      rethrow;
    } finally {
      isLoggingIn.value = false;
    }
  }
}
