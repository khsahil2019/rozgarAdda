import 'package:get/get.dart';
import '../../data/data_source/kyc_remote_datasource.dart';
import '../../data/repository/kyc_repository_impl.dart';
import '../../domain/repository/kyc_repository.dart';
import '../controller/kyc_controller.dart';

class KycBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KycRemoteDataSource>(() => KycRemoteDataSourceImpl());
    Get.lazyPut<KycRepository>(
      () => KycRepositoryImpl(
        remoteDataSource: Get.find<KycRemoteDataSource>(),
      ),
    );
    Get.lazyPut(() => KycController(repository: Get.find<KycRepository>()));
  }
}
