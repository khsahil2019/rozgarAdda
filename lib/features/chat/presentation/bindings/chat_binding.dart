import 'package:get/get.dart';
import '../../data/data_source/chat_remote_datasource.dart';
import '../../data/repository/chat_repository_impl.dart';
import '../../domain/repository/chat_repository.dart';
import '../controller/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(),
    );
    Get.lazyPut<ChatRepository>(
      () => ChatRepositoryImpl(remoteDataSource: Get.find()),
    );
    Get.lazyPut<ChatController>(
      () => ChatController(repository: Get.find()),
    );
  }
}
