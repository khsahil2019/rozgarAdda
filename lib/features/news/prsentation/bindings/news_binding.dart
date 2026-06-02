import 'package:get/get.dart';
import '../../data/data_source/news_remote_datasource.dart';
import '../../data/repository/news_repository_impl.dart';
import '../../domain/repository/news_repository.dart';
import '../controller/news_controller.dart';

class NewsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewsRemoteDataSource>(() => NewsRemoteDataSourceImpl());
    Get.lazyPut<NewsRepository>(() => NewsRepositoryImpl(remoteDataSource: Get.find()));
    Get.lazyPut(() => NewsController(repository: Get.find()));
  }
}
