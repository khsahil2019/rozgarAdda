import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/core/network/api_routes.dart';
import 'package:rojgar/core/network/api_services.dart';
import '../model/text_news_model.dart';
import '../model/video_news_model.dart';
import '../model/youtube_news_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<TextNewsModel>> getTextNews();
  Future<List<VideoNewsModel>> getVideoNews();
  Future<List<YoutubeNewsModel>> getYoutubeNews();
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  @override
  Future<List<TextNewsModel>> getTextNews() async {
    try {
      final res = await ApiService.get(ApiRoutes.textNews);
      if (res['statusCode'] == 200 && res['status'] == true) {
        final List<dynamic> dataList = res['data'] as List<dynamic>? ?? [];
        return dataList
            .map((json) => TextNewsModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Failure(res['message'] ?? 'Failed to fetch text news');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to fetch text news');
    }
  }

  @override
  Future<List<VideoNewsModel>> getVideoNews() async {
    try {
      final res = await ApiService.get(ApiRoutes.videoNews);
      if (res['statusCode'] == 200 && res['status'] == true) {
        final List<dynamic> dataList = res['data'] as List<dynamic>? ?? [];
        return dataList
            .map((json) => VideoNewsModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Failure(res['message'] ?? 'Failed to fetch video news');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to fetch video news');
    }
  }

  @override
  Future<List<YoutubeNewsModel>> getYoutubeNews() async {
    try {
      final res = await ApiService.get(ApiRoutes.videosNews);
      if (res['statusCode'] == 200) {
        final List<dynamic> dataList = res['data'] as List<dynamic>? ?? [];
        return dataList
            .map((json) => YoutubeNewsModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Failure('Failed to fetch YouTube news');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to fetch YouTube news');
    }
  }
}
