import 'package:fpdart/fpdart.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../entities/chat_entities.dart';

abstract class ChatRepository {
  Future<Either<Failure, int>> startChat(int sellId);
  Future<Either<Failure, List<ChatEnquiry>>> getMyEnquiries();
  Future<Either<Failure, ChatDetails>> getChatMessages(int chatId);
  Future<Either<Failure, ChatMessage>> sendChatMessage(
    int chatId,
    String message, {
    String? filePath,
  });
}
