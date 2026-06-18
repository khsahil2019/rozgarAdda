import 'package:get/get.dart';
import '../controllers/employer_dashboard_controller.dart';

class EmployerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmployerDashboardController());
  }
}
