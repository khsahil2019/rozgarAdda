// core/bindings/initial_binding.dart  ← runs at app start
import 'package:get/get.dart';

import '../../features/app/app_controller.dart';
import '../../features/auth/presentation/controller/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Always alive — global controllers
    Get.put(AppController(), permanent: true);
    Get.put(AuthController(), permanent: true);
  }
}

// features/home/presentation/bindings/home_binding.dart
// class HomeBinding extends Bindings {
//   @override
//   void dependencies() {
//     // Lazy — only when Home screen is opened
//     Get.lazyPut(() => HomeController());
//   }
// }
