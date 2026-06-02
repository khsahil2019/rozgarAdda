import 'package:get/get.dart';
import 'package:rojgar/features/auth/data/data_source/auth_remote_datasource.dart';
import 'package:rojgar/features/auth/data/repository/auth_repository_impl.dart';
import 'package:rojgar/features/auth/domain/repository/auth_repository.dart';
import 'package:rojgar/features/auth/presentation/controller/auth_controller.dart';
import 'package:rojgar/features/auth/presentation/controller/login_controller.dart';
import 'package:rojgar/features/auth/presentation/controller/register_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: Get.find<AuthRemoteDataSource>()),
    );
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<LoginController>(
      () => LoginController(authRepository: Get.find<AuthRepository>()),
    );
    Get.lazyPut<RegisterController>(
      () => RegisterController(authRepository: Get.find<AuthRepository>()),
    );
  }
}
