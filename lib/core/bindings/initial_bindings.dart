// core/bindings/initial_binding.dart  ← runs at app start
import 'package:get/get.dart';

import '../../features/app/app_controller.dart';
import '../../features/auth/presentation/bindings/auth_binding.dart';
import '../../features/auth/presentation/controller/auth_controller.dart';
import '../../features/news/prsentation/bindings/news_binding.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Always alive — global controllers
    Get.put(AppController(), permanent: true);

    // Reuse AuthBinding to register auth dependencies lazily
    AuthBinding().dependencies();

    // Promote AuthController to permanent
    Get.put<AuthController>(Get.find<AuthController>(), permanent: true);

    // Register news dependencies
    NewsBinding().dependencies();
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
