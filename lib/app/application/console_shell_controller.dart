import 'package:get/get.dart';

class ConsoleShellController extends GetxController {
  final isSidebarExpanded = false.obs;

  void toggleSidebar() {
    isSidebarExpanded.value = !isSidebarExpanded.value;
  }
}
