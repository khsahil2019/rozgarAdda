import 'package:get/get.dart';
import '../../data/data_source/sell_product_remote_datasource.dart';
import '../../data/repository/sell_product_repository_impl.dart';
import '../../domain/repository/sell_product_repository.dart';
import '../controller/sell_product_controller.dart';

class SellProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellProductRemoteDataSource>(
      () => SellProductRemoteDataSourceImpl(),
    );
    Get.lazyPut<SellProductRepository>(
      () => SellProductRepositoryImpl(remoteDataSource: Get.find()),
    );
    Get.lazyPut<SellProductController>(
      () => SellProductController(repository: Get.find()),
    );
  }
}
