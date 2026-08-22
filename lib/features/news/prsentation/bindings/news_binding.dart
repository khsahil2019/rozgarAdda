import 'package:get/get.dart';
import '../../data/data_source/news_remote_datasource.dart';
import '../../data/repository/news_repository_impl.dart';
import '../../domain/repository/news_repository.dart';
import '../controller/create_news_controller.dart';
import '../controller/news_controller.dart';

class NewsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewsRemoteDataSource>(() => NewsRemoteDataSourceImpl());
    Get.lazyPut<NewsRepository>(
      () => NewsRepositoryImpl(remoteDataSource: Get.find()),
    );
    Get.lazyPut(() => NewsController(repository: Get.find()));
  }
}

/// Scoped to the create-news route so the form state is rebuilt each visit.
class CreateNewsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NewsRemoteDataSource>()) {
      Get.lazyPut<NewsRemoteDataSource>(() => NewsRemoteDataSourceImpl());
    }
    if (!Get.isRegistered<NewsRepository>()) {
      Get.lazyPut<NewsRepository>(
        () => NewsRepositoryImpl(remoteDataSource: Get.find()),
      );
    }
    Get.lazyPut(() => CreateNewsController(repository: Get.find()));
  }
}
