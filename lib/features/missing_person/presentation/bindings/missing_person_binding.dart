import 'package:get/get.dart';
import '../../data/data_source/missing_person_remote_datasource.dart';
import '../../data/repository/missing_person_repository_impl.dart';
import '../../domain/repository/missing_person_repository.dart';
import '../controller/missing_person_controller.dart';

class MissingPersonBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MissingPersonRemoteDataSource>(() => MissingPersonRemoteDataSourceImpl());
    Get.lazyPut<MissingPersonRepository>(() => MissingPersonRepositoryImpl(remoteDataSource: Get.find()));
    Get.lazyPut(() => MissingPersonController(repository: Get.find()));
  }
}
