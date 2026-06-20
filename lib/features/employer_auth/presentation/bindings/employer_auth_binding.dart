import 'package:get/get.dart';
import '../../data/repositories/employer_auth_repository_impl.dart';
import '../../domain/repositories/employer_auth_repository.dart';
import '../controllers/employer_login_controller.dart';
import '../controllers/employer_register_controller.dart';

class EmployerAuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployerAuthRepository>(() => EmployerAuthRepositoryImpl());
    Get.lazyPut(() => EmployerLoginController(authRepository: Get.find()));
    Get.lazyPut(() => EmployerRegisterController(authRepository: Get.find()));
  }
}
