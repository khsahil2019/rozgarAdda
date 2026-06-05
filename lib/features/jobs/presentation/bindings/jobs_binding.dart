import 'package:get/get.dart';
import '../../data/data_source/jobs_remote_datasource.dart';
import '../../data/repository/jobs_repository_impl.dart';
import '../../domain/repository/jobs_repository.dart';
import '../controller/job_application_controller.dart';
import '../controller/jobs_controller.dart';

class JobsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobsRemoteDataSource>(() => JobsRemoteDataSourceImpl());
    Get.lazyPut<JobsRepository>(
      () => JobsRepositoryImpl(remoteDataSource: Get.find<JobsRemoteDataSource>()),
    );
    Get.lazyPut(() => JobsController(repository: Get.find<JobsRepository>()));
    Get.lazyPut(() => JobApplicationController(repository: Get.find<JobsRepository>()));
  }
}
