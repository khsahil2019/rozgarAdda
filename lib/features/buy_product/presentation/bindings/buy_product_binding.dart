import 'package:get/get.dart';
import '../../data/data_source/buy_product_remote_datasource.dart';
import '../../data/repository/buy_product_repository_impl.dart';
import '../../domain/repository/buy_product_repository.dart';
import '../controller/buy_product_controller.dart';

class BuyProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BuyProductRemoteDataSource>(
      () => BuyProductRemoteDataSourceImpl(),
    );
    Get.lazyPut<BuyProductRepository>(
      () => BuyProductRepositoryImpl(remoteDataSource: Get.find()),
    );
    Get.lazyPut<BuyProductController>(
      () => BuyProductController(repository: Get.find()),
    );
  }
}
