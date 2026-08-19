import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/core/network/api_routes.dart';
import 'package:rojgar/core/network/api_services.dart';
import '../model/news_category_model.dart';
import '../model/news_state_model.dart';
import '../model/pagination_model.dart';
import '../model/text_news_model.dart';
import '../model/video_news_model.dart';

/// A decoded `{ data: [...], pagination: {...} }` listing response.
class PagedResponse<T> {
  final List<T> items;
  final PaginationModel pagination;

  PagedResponse({required this.items, required this.pagination});
}

abstract class NewsRemoteDataSource {
  Future<List<NewsCategoryModel>> getCategories();
  Future<List<NewsStateModel>> getStates();
  Future<PagedResponse<TextNewsModel>> getTextNews({
    required int categoryId,
    required int stateId,
    required int page,
    required int perPage,
  });
  Future<PagedResponse<VideoNewsModel>> getVideoNews({
    required int categoryId,
    required int stateId,
    required int page,
    required int perPage,
  });
  Future<String> createNews({
    required int categoryId,
    required int stateId,
    required String title,
    required String description,
    String? imagePath,
  });
  Future<String> createVideoNews({
    required int categoryId,
    required int stateId,
    required String title,
    required String subject,
    required String videoPath,
  });
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  @override
  Future<List<NewsCategoryModel>> getCategories() async {
    try {
      final res = await ApiService.get(ApiRoutes.newsCategories);
      if (res['statusCode'] == 200 && res['status'] == true) {
        final List<dynamic> data = res['data'] as List<dynamic>? ?? [];
        return data
            .map((e) => NewsCategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Failure(
        res['message']?.toString() ?? 'Failed to load news categories',
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to load news categories');
    }
  }

  @override
  Future<List<NewsStateModel>> getStates() async {
    try {
      final res = await ApiService.get(ApiRoutes.states);
      if (res['statusCode'] == 200 && res['status'] == true) {
        final List<dynamic> data = res['data'] as List<dynamic>? ?? [];
        return data
            .map((e) => NewsStateModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Failure(res['message']?.toString() ?? 'Failed to load states');
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to load states');
    }
  }

  @override
  Future<PagedResponse<TextNewsModel>> getTextNews({
    required int categoryId,
    required int stateId,
    required int page,
    required int perPage,
  }) async {
    return _getPaged(
      url: ApiRoutes.textNews,
      categoryId: categoryId,
      stateId: stateId,
      page: page,
      perPage: perPage,
      parse: (json) => TextNewsModel.fromJson(json),
      errorMessage: 'Failed to fetch text news',
    );
  }

  @override
  Future<PagedResponse<VideoNewsModel>> getVideoNews({
    required int categoryId,
    required int stateId,
    required int page,
    required int perPage,
  }) async {
    return _getPaged(
      url: ApiRoutes.videoNews,
      categoryId: categoryId,
      stateId: stateId,
      page: page,
      perPage: perPage,
      parse: (json) => VideoNewsModel.fromJson(json),
      errorMessage: 'Failed to fetch video news',
    );
  }

  Future<PagedResponse<T>> _getPaged<T>({
    required String url,
    required int categoryId,
    required int stateId,
    required int page,
    required int perPage,
    required T Function(Map<String, dynamic> json) parse,
    required String errorMessage,
  }) async {
    try {
      final res = await ApiService.get(
        url,
        queryParameters: {
          'category_id': categoryId,
          'state_id': stateId,
          'page': page,
          'per_page': perPage,
        },
      );
      if (res['statusCode'] == 200 && res['status'] == true) {
        final List<dynamic> data = res['data'] as List<dynamic>? ?? [];
        final items = data
            .map((e) => parse(e as Map<String, dynamic>))
            .toList();
        return PagedResponse(
          items: items,
          pagination: PaginationModel.fromJson(
            res['pagination'] as Map<String, dynamic>?,
            itemCount: items.length,
          ),
        );
      }
      throw Failure(res['message']?.toString() ?? errorMessage);
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure(errorMessage);
    }
  }

  @override
  Future<String> createNews({
    required int categoryId,
    required int stateId,
    required String title,
    required String description,
    String? imagePath,
  }) async {
    try {
      final res = await ApiService.uploadFiles(
        method: 'POST',
        url: ApiRoutes.storeNews,
        fields: {
          'category_id': categoryId.toString(),
          'state_id': stateId.toString(),
          'title': title,
          'description': description,
        },
        files: {
          if (imagePath != null && imagePath.isNotEmpty) 'image': imagePath,
        },
      );
      final statusCode = res['statusCode'] as int? ?? 0;
      if ((statusCode == 200 || statusCode == 201) && res['status'] != false) {
        return res['message']?.toString() ?? 'News submitted successfully.';
      }
      throw Failure(res['message']?.toString() ?? 'Failed to submit news');
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to submit news');
    }
  }

  @override
  Future<String> createVideoNews({
    required int categoryId,
    required int stateId,
    required String title,
    required String subject,
    required String videoPath,
  }) async {
    try {
      final res = await ApiService.uploadFiles(
        method: 'POST',
        url: ApiRoutes.storeVideo,
        fields: {
          'category_id': categoryId.toString(),
          'state_id': stateId.toString(),
          'title': title,
          'subject': subject,
        },
        files: {
          if (videoPath.isNotEmpty) 'video': videoPath,
        },
      );
      final statusCode = res['statusCode'] as int? ?? 0;
      if ((statusCode == 200 || statusCode == 201) && res['status'] != false) {
        return res['message']?.toString() ?? 'Video news submitted successfully.';
      }
      throw Failure(res['message']?.toString() ?? 'Failed to submit video news');
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to submit video news');
    }
  }
}
