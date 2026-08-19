import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import '../../domain/entities/news_category.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/entities/news_page.dart';
import '../../domain/entities/news_state.dart';
import '../../domain/repository/news_repository.dart';
import '../data_source/news_remote_datasource.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;

  NewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<NewsCategory>>> getCategories() {
    return _guard(() async {
      final models = await remoteDataSource.getCategories();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<NewsState>>> getStates() {
    return _guard(() async {
      final models = await remoteDataSource.getStates();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, NewsPage<TextNews>>> getTextNews({
    required int categoryId,
    required int stateId,
    int page = 1,
    int perPage = 10,
  }) {
    return _guard(() async {
      final res = await remoteDataSource.getTextNews(
        categoryId: categoryId,
        stateId: stateId,
        page: page,
        perPage: perPage,
      );
      return NewsPage<TextNews>(
        items: res.items.map((m) => m.toEntity()).toList(),
        pagination: res.pagination.toEntity(),
      );
    });
  }

  @override
  Future<Either<Failure, NewsPage<VideoNews>>> getVideoNews({
    required int categoryId,
    required int stateId,
    int page = 1,
    int perPage = 10,
  }) {
    return _guard(() async {
      final res = await remoteDataSource.getVideoNews(
        categoryId: categoryId,
        stateId: stateId,
        page: page,
        perPage: perPage,
      );
      return NewsPage<VideoNews>(
        items: res.items.map((m) => m.toEntity()).toList(),
        pagination: res.pagination.toEntity(),
      );
    });
  }

  @override
  Future<Either<Failure, String>> createNews({
    required int categoryId,
    required int stateId,
    required String title,
    required String description,
    String? imagePath,
  }) {
    return _guard(() {
      return remoteDataSource.createNews(
        categoryId: categoryId,
        stateId: stateId,
        title: title,
        description: description,
        imagePath: imagePath,
      );
    });
  }

  @override
  Future<Either<Failure, String>> createVideoNews({
    required int categoryId,
    required int stateId,
    required String title,
    required String subject,
    required String videoPath,
  }) {
    return _guard(() {
      return remoteDataSource.createVideoNews(
        categoryId: categoryId,
        stateId: stateId,
        title: title,
        subject: subject,
        videoPath: videoPath,
      );
    });
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }
}
