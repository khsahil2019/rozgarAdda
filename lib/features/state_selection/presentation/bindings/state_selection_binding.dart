import 'package:get/get.dart';
import '../../data/data_source/state_remote_datasource.dart';
import '../../data/repository/state_repository_impl.dart';
import '../../domain/repository/state_repository.dart';
import '../controller/select_state_controller.dart';

class StateSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StateRemoteDataSource>(() => StateRemoteDataSourceImpl());
    Get.lazyPut<StateRepository>(
      () => StateRepositoryImpl(remoteDataSource: Get.find<StateRemoteDataSource>()),
    );
    Get.lazyPut<SelectStateController>(
      () => SelectStateController(Get.find<StateRepository>()),
    );
  }
}
