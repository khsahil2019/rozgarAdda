import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/repository/news_repository.dart';
import '../data_source/news_remote_datasource.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;

  NewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TextNews>>> getTextNews() async {
    try {
      final models = await remoteDataSource.getTextNews();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VideoNews>>> getVideoNews() async {
    try {
      final models = await remoteDataSource.getVideoNews();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<YoutubeNews>>> getYoutubeNews() async {
    try {
      final models = await remoteDataSource.getYoutubeNews();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }
}
