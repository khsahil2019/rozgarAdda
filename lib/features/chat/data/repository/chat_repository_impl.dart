import 'package:fpdart/fpdart.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/repository/chat_repository.dart';
import '../data_source/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, int>> startChat(int sellId) async {
    try {
      final chatId = await remoteDataSource.startChat(sellId);
      return Right(chatId);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatEnquiry>>> getMyEnquiries() async {
    try {
      final enquiries = await remoteDataSource.getMyEnquiries();
      return Right(enquiries);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatDetails>> getChatMessages(int chatId) async {
    try {
      final details = await remoteDataSource.getChatMessages(chatId);
      return Right(details);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendChatMessage(
    int chatId,
    String message, {
    String? filePath,
  }) async {
    try {
      final sentMessage = await remoteDataSource.sendChatMessage(
        chatId,
        message,
        filePath: filePath,
      );
      return Right(sentMessage);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
