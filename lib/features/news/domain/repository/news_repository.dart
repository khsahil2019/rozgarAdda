import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import '../entities/news_category.dart';
import '../entities/news_item.dart';
import '../entities/news_page.dart';
import '../entities/news_state.dart';

abstract class NewsRepository {
  Future<Either<Failure, List<NewsCategory>>> getCategories();

  Future<Either<Failure, List<NewsState>>> getStates();

  Future<Either<Failure, NewsPage<TextNews>>> getTextNews({
    required int categoryId,
    required int stateId,
    int page,
    int perPage,
  });

  Future<Either<Failure, NewsPage<VideoNews>>> getVideoNews({
    required int categoryId,
    required int stateId,
    int page,
    int perPage,
  });

  /// Returns the success message reported by the API.
  Future<Either<Failure, String>> createNews({
    required int categoryId,
    required int stateId,
    required String title,
    required String description,
    String? imagePath,
  });

  Future<Either<Failure, String>> createVideoNews({
    required int categoryId,
    required int stateId,
    required String title,
    required String subject,
    required String videoPath,
  });
}
