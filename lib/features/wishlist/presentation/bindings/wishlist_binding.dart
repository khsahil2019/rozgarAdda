import 'package:get/get.dart';
import '../../data/data_source/wishlist_datasource.dart';
import '../../data/repository/wishlist_repository_impl.dart';
import '../../domain/repository/wishlist_repository.dart';
import '../controller/wishlist_controller.dart';

class WishlistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WishlistDataSource>(() => WishlistDataSourceImpl());
    Get.lazyPut<WishlistRepository>(
      () => WishlistRepositoryImpl(dataSource: Get.find<WishlistDataSource>()),
    );
    Get.lazyPut<WishlistController>(
      () => WishlistController(repository: Get.find<WishlistRepository>()),
      fenix: true,
    );
  }
}

