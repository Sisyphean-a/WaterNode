import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:waternode/core/network/api_client.dart';
import 'package:waternode/core/network/dynamic_header_factory.dart';
import 'package:waternode/features/auth/domain/gateways/auth_gateway.dart';
import 'package:waternode/features/auth/domain/models/auth_session.dart';
import 'package:waternode/features/auth/infrastructure/auth_api.dart';
import 'package:waternode/features/auth/infrastructure/token_payload_parser.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';
import 'package:waternode/features/credentials/domain/repositories/account_repository.dart';
import 'package:waternode/features/credentials/infrastructure/hive_account_repository.dart';
import 'package:waternode/features/credentials/infrastructure/memory_account_repository.dart';
import 'package:waternode/features/dashboard/domain/gateways/activity_gateway.dart';
import 'package:waternode/features/dashboard/domain/models/account_status.dart';
import 'package:waternode/features/dashboard/infrastructure/activity_api.dart';
import 'package:waternode/features/devices/domain/gateways/device_gateway.dart';
import 'package:waternode/features/devices/infrastructure/device_api.dart';
import 'package:waternode/features/devices/infrastructure/memory_device_gateway.dart';

class AppDependencies {
  const AppDependencies({
    required this.accountRepository,
    required this.authGateway,
    required this.activityGateway,
    required this.deviceGateway,
    required this.tokenPayloadParser,
  });

  final AccountRepository accountRepository;
  final AuthGateway authGateway;
  final ActivityGateway activityGateway;
  final DeviceGateway deviceGateway;
  final TokenPayloadParser tokenPayloadParser;

  static Future<AppDependencies> createDefault() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<dynamic>(HiveAccountRepository.boxName);
    final parser = TokenPayloadParser();
    final headers = DynamicHeaderFactory(parser);
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://gateway.exiaokang.cn',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    final client = ApiClient(dio);

    return AppDependencies(
      accountRepository: HiveAccountRepository(box),
      authGateway: AuthApi(client, headers),
      activityGateway: ActivityApi(client, headers),
      deviceGateway: DeviceApi(client, headers),
      tokenPayloadParser: parser,
    );
  }

  static AppDependencies inMemory() {
    final parser = TokenPayloadParser();
    final repository = MemoryAccountRepository(<AccountCredential>[
      AccountCredential(
        mobile: '15700000000',
        token: _buildInMemoryToken(),
        platformType: 'CUSTOMER_APP',
        deviceId: 'memory-device',
        userId: 'memory-user',
        points: 3,
        isValid: true,
      ),
    ]);
    return AppDependencies(
      accountRepository: repository,
      authGateway: const _StubAuthGateway(),
      activityGateway: const _StubActivityGateway(),
      deviceGateway: const MemoryDeviceGateway(),
      tokenPayloadParser: parser,
    );
  }

  static String _buildInMemoryToken() {
    return 'eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.'
        'eyJwbGF0Zm9ybVR5cGUiOiJDVVNUT01FUl9BUF'
        'AiLCJkZXZpY2VJZCI6Im1lbW9yeS1kZXZpY2UiLCJ1c2VySWQiOiJtZW1vcnktdXNlciJ9.'
        'signature';
  }
}

class _StubAuthGateway implements AuthGateway {
  const _StubAuthGateway();

  @override
  Future<AuthSession> login({
    required String mobile,
    required String smsCode,
    required String smsCodeId,
  }) {
    throw UnimplementedError('测试依赖未提供 AuthGateway');
  }

  @override
  Future<String> sendCode(String mobile) {
    throw UnimplementedError('测试依赖未提供 AuthGateway');
  }
}

class _StubActivityGateway implements ActivityGateway {
  const _StubActivityGateway();

  @override
  Future<AccountStatus> fetchStatus(AccountCredential credential) async {
    return AccountStatus(
      isValid: credential.isValid,
      points: credential.points,
    );
  }

  @override
  Future<void> luckDraw(
    AccountCredential credential, {
    required String townCode,
  }) {
    throw UnimplementedError('测试依赖未提供 ActivityGateway');
  }

  @override
  Future<void> signIn(AccountCredential credential) {
    throw UnimplementedError('测试依赖未提供 ActivityGateway');
  }
}
