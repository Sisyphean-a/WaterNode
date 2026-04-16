import 'package:get/get.dart';
import 'package:waternode/app/application/console_shell_controller.dart';
import 'package:waternode/app/dependencies/app_dependencies.dart';
import 'package:waternode/features/auth/application/auth_controller.dart';
import 'package:waternode/features/credentials/application/credential_controller.dart';
import 'package:waternode/features/dashboard/application/dashboard_controller.dart';
import 'package:waternode/features/devices/application/device_controller.dart';

class AppBinding extends Bindings {
  AppBinding(this._dependencies);

  final AppDependencies _dependencies;

  @override
  void dependencies() {
    Get.put(ConsoleShellController(), permanent: true);
    Get.find<ConsoleShellController>().reset();
    Get.put(_dependencies.accountRepository, permanent: true);
    Get.put(_dependencies.accountProfileGateway, permanent: true);
    Get.put(_dependencies.authGateway, permanent: true);
    Get.put(_dependencies.activityGateway, permanent: true);
    Get.put(_dependencies.deviceGateway, permanent: true);
    Get.put(_dependencies.tokenPayloadParser, permanent: true);

    Get.put(
      CredentialController(
        _dependencies.accountRepository,
        _dependencies.activityGateway,
        _dependencies.tokenPayloadParser,
        _dependencies.accountProfileGateway,
      ),
      permanent: true,
    );
    Get.put(
      AuthController(
        _dependencies.authGateway,
        _dependencies.accountRepository,
        _dependencies.tokenPayloadParser,
        onCredentialSaved: () async {
          await Get.find<CredentialController>().load();
          await Get.find<CredentialController>().refreshStatuses();
        },
      ),
      permanent: true,
    );
    Get.put(
      DashboardController(
        Get.find<CredentialController>(),
        _dependencies.activityGateway,
      ),
      permanent: true,
    );
    Get.put(
      DeviceController(
        Get.find<CredentialController>(),
        _dependencies.deviceGateway,
      ),
      permanent: true,
    );
  }
}
