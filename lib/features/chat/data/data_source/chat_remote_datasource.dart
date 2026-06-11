import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/network/api_services.dart';
import '../../domain/entities/chat_entities.dart';
import '../model/chat_dtos.dart';

abstract class ChatRemoteDataSource {
  Future<int> startChat(int sellId);
  Future<List<ChatEnquiryModel>> getMyEnquiries();
  Future<ChatDetailsModel> getChatMessages(int chatId);
  Future<ChatMessageModel> sendChatMessage(
    int chatId,
    String message, {
    String? filePath,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  @override
  Future<int> startChat(int sellId) async {
    try {
      final res = await ApiService.request(
        method: 'POST',
        url: ApiRoutes.startChat,
        body: {'sell_id': sellId},
      );
      if (res['statusCode'] == 200 && res['success'] == true) {
        final rawId = res['chat_id'];
        if (rawId is int) {
          return rawId;
        }
        return int.tryParse(rawId?.toString() ?? '') ?? 0;
      } else {
        throw Failure(res['message'] ?? 'Failed to start chat');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to start chat. Please check your connection.');
    }
  }

  @override
  Future<List<ChatEnquiryModel>> getMyEnquiries() async {
    try {
      final res = await ApiService.request(
        method: 'GET',
        url: ApiRoutes.myEnquiries,
      );
      if (res['statusCode'] == 200 && res['success'] == true) {
        final List<dynamic> data = res['chats'] ?? [];
        return data
            .map(
              (json) => ChatEnquiryModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Failure(res['message'] ?? 'Failed to load chat enquiries');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure(
        'Failed to load chat enquiries. Please check your connection.',
      );
    }
  }

  @override
  Future<ChatDetailsModel> getChatMessages(int chatId) async {
    try {
      final res = await ApiService.request(
        method: 'GET',
        url: ApiRoutes.chatMessages(chatId),
      );
      if (res['statusCode'] == 200 && res['success'] == true) {
        final List<dynamic> rawMsgs = res['messages'] ?? [];
        final messages = rawMsgs
            .map(
              (json) => ChatMessageModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        final chatInfo = ChatInfoModel.fromJson(
          Map<String, dynamic>.from(res['chat_info'] ?? {}),
        );
        return ChatDetailsModel(messages: messages, chatInfo: chatInfo);
      } else {
        throw Failure(res['message'] ?? 'Failed to load messages');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to load messages. Please check your connection.');
    }
  }

  @override
  Future<ChatMessageModel> sendChatMessage(
    int chatId,
    String message, {
    String? filePath,
  }) async {
    try {
      final Map<String, dynamic> res;
      if (filePath != null && filePath.isNotEmpty) {
        res = await ApiService.uploadFiles(
          method: 'POST',
          url: ApiRoutes.sendMessage(chatId),
          fields: {'message': message},
          files: {'file': filePath},
        );
      } else {
        // Send via form-data style since the API expects it for form requests,
        // or standard POST request body depending on backend requirements.
        // Let's use uploadFiles with empty files list to force multipart/form-data
        // as we verified it works with curl form parameters.
        res = await ApiService.uploadFiles(
          method: 'POST',
          url: ApiRoutes.sendMessage(chatId),
          fields: {'message': message},
          files: {},
        );
      }

      if (res['statusCode'] == 200 && res['success'] == true) {
        final msgData = res['message'];
        if (msgData == null) {
          throw Failure('Failed to retrieve sent message');
        }
        return ChatMessageModel.fromJson(msgData as Map<String, dynamic>);
      } else {
        throw Failure(res['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to send message. Please check your connection.');
    }
  }
}

class ChatDetailsModel extends ChatDetails {
  const ChatDetailsModel({required super.messages, required super.chatInfo});
}
