import 'package:get/get.dart';
import 'package:waternode/features/auth/infrastructure/token_payload_parser.dart';
import 'package:waternode/features/credentials/domain/models/account_sign_in_state.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/credentials/domain/gateways/account_profile_gateway.dart';
import 'package:waternode/features/credentials/domain/repositories/account_repository.dart';
import 'package:waternode/features/dashboard/domain/gateways/activity_gateway.dart';

const Object _noChange = Object();

class CredentialController extends GetxController {
  CredentialController(
    this._repository,
    this._activityGateway,
    [
      TokenPayloadParser? parser,
      AccountProfileGateway? accountProfileGateway,
    ]
  ) : _parser = parser ?? TokenPayloadParser(),
      _accountProfileGateway =
          accountProfileGateway ?? const _UnsupportedAccountProfileGateway();

  final AccountRepository _repository;
  final ActivityGateway _activityGateway;
  final TokenPayloadParser _parser;
  final AccountProfileGateway _accountProfileGateway;

  final credentials = <AccountCredential>[].obs;
  final isRefreshing = false.obs;
  final isImporting = false.obs;
  final lastError = RxnString();
  Future<void>? _refreshTask;

  int get totalCount => credentials.length;
  int get validCount => credentials.where((item) => item.isValid).length;
  int get invalidCount => totalCount - validCount;
  int get totalPoints => credentials.fold(0, (sum, item) => sum + item.points);

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> load() async {
    credentials.assignAll(await _repository.readAll());
  }

  Future<void> refreshStatuses() async {
    final activeTask = _refreshTask;
    if (activeTask != null) {
      return activeTask;
    }
    final task = _performRefreshStatuses();
    _refreshTask = task;
    await task.whenComplete(() {
      _refreshTask = null;
    });
  }

  Future<void> _bootstrap() async {
    await load();
    if (credentials.isEmpty) {
      return;
    }
    try {
      await refreshStatuses();
    } catch (_) {}
  }

  Future<void> _performRefreshStatuses() async {
    isRefreshing.value = true;
    lastError.value = null;
    try {
      final current = await _repository.readAll();
      if (current.isEmpty) {
        credentials.clear();
        return;
      }
      final updated = <AccountCredential>[];
      for (final credential in current) {
        final status = await _activityGateway.fetchStatus(credential);
        updated.add(
          credential.copyWith(
            points: status.points,
            isValid: status.isValid,
            signInState: status.signInState,
            lastCheckedAt: DateTime.now(),
          ),
        );
      }
      await _repository.saveAll(updated);
      credentials.assignAll(updated);
    } catch (error) {
      lastError.value = error.toString();
      rethrow;
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> importToken(String rawToken) async {
    isImporting.value = true;
    lastError.value = null;
    try {
      final token = rawToken.trim();
      if (token.isEmpty) {
        throw const FormatException('Token 不能为空');
      }
      final payload = _parser.parse(token);
      final mobile = await _accountProfileGateway.fetchMobile(token);
      await _repository.save(
        AccountCredential(
          mobile: mobile,
          token: token,
          platformType: payload.platformType,
          deviceId: payload.deviceId,
          userId: payload.userId,
          points: 0,
          isValid: true,
          lastCheckedAt: DateTime.now(),
        ),
      );
      await load();
    } catch (error) {
      lastError.value = error.toString();
      rethrow;
    } finally {
      isImporting.value = false;
    }
  }

  Future<void> updateAccountMeta(
    AccountCredential credential, {
    Object? remark = _noChange,
    Object? defaultRegionCode = _noChange,
    AccountSignInState? signInState,
  }) async {
    final updated = credential.copyWith(
      remark: remark,
      defaultRegionCode: defaultRegionCode,
      signInState: signInState,
    );
    await _repository.save(updated);
    final next = credentials
        .map((item) => item.mobile == credential.mobile ? updated : item)
        .toList(growable: false);
    credentials.assignAll(next);
  }
}

class _UnsupportedAccountProfileGateway implements AccountProfileGateway {
  const _UnsupportedAccountProfileGateway();

  @override
  Future<String> fetchMobile(String token) {
    throw UnimplementedError('导入 Token 需要提供 AccountProfileGateway');
  }
}
