import 'package:get/get.dart';
import '../../data/data_source/employer_dashboard_remote_datasource.dart';
import '../../data/repository/employer_dashboard_repository_impl.dart';
import '../../domain/repository/employer_dashboard_repository.dart';
import '../controllers/employer_dashboard_controller.dart';

class EmployerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployerDashboardRemoteDataSource>(
      () => EmployerDashboardRemoteDataSourceImpl(),
    );
    Get.lazyPut<EmployerDashboardRepository>(
      () => EmployerDashboardRepositoryImpl(
        remoteDataSource: Get.find<EmployerDashboardRemoteDataSource>(),
      ),
    );
    Get.lazyPut(() => EmployerDashboardController(
          repository: Get.find<EmployerDashboardRepository>(),
        ));
  }
}
