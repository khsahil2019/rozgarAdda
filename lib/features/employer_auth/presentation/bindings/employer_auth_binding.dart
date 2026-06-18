import 'package:get/get.dart';
import '../../data/repositories/mock_employer_auth_repository.dart';
import '../../domain/repositories/employer_auth_repository.dart';
import '../controllers/employer_login_controller.dart';
import '../controllers/employer_register_controller.dart';

class EmployerAuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployerAuthRepository>(() => MockEmployerAuthRepository());
    Get.lazyPut(() => EmployerLoginController(authRepository: Get.find()));
    Get.lazyPut(() => EmployerRegisterController(authRepository: Get.find()));
  }
}
