import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import '../entities/news_item.dart';

abstract class NewsRepository {
  Future<Either<Failure, List<TextNews>>> getTextNews();
  Future<Either<Failure, List<VideoNews>>> getVideoNews();
  Future<Either<Failure, List<YoutubeNews>>> getYoutubeNews();
}
