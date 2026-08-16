import 'package:get/get.dart';
import '../../data/data_source/profile_remote_datasource.dart';
import '../../data/repository/profile_repository_impl.dart';
import '../../domain/repository/profile_repository.dart';
import '../controller/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl());
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepositoryImpl(
        remoteDataSource: Get.find<ProfileRemoteDataSource>(),
      ),
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(repository: Get.find<ProfileRepository>()),
    );
  }
}
