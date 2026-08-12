import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rojgar/features/news/data/model/news_category_model.dart';
import 'package:rojgar/features/news/data/model/news_state_model.dart';
import 'package:rojgar/features/news/data/model/pagination_model.dart';
import 'package:rojgar/features/news/data/model/text_news_model.dart';
import 'package:rojgar/features/news/data/model/video_news_model.dart';

void main() {
  group('NewsCategoryModel', () {
    test('parses the /api/news-categories payload', () {
      final json =
          jsonDecode('{"id":10,"name":"Business","slug":"business"}')
              as Map<String, dynamic>;

      final entity = NewsCategoryModel.fromJson(json).toEntity();

      expect(entity.id, 10);
      expect(entity.name, 'Business');
      expect(entity.slug, 'business');
    });
  });

  group('NewsStateModel', () {
    test('parses the /api/states payload', () {
      final json =
          jsonDecode('{"id":28,"name":"West Bengal"}') as Map<String, dynamic>;

      final entity = NewsStateModel.fromJson(json).toEntity();

      expect(entity.id, 28);
      expect(entity.name, 'West Bengal');
    });
  });

  group('TextNewsModel', () {
    test('parses a /api/text-news item with nested category and state', () {
      final json =
          jsonDecode('''
        {
          "id": 12,
          "title": "Lakhimpur Kheri",
          "category_id": 7,
          "state_id": 28,
          "description": "Body text",
          "image": "news/1783940409.png",
          "status": "approved",
          "is_seen": 1,
          "added_by": 11,
          "created_at": "2026-07-13T11:00:09.000000Z",
          "updated_at": "2026-08-11T01:21:17.000000Z",
          "image_url": "https://rozgaradda.com/news/1783940409.png",
          "category": {"id": 7, "name": "National News", "slug": "national-news"},
          "state": {"id": 28, "name": "West Bengal"}
        }
      ''')
              as Map<String, dynamic>;

      final entity = TextNewsModel.fromJson(json).toEntity();

      expect(entity.id, 12);
      expect(entity.categoryId, 7);
      expect(entity.stateId, 28);
      expect(entity.categoryName, 'National News');
      expect(entity.stateName, 'West Bengal');
      expect(entity.imageUrl, 'https://rozgaradda.com/news/1783940409.png');
      expect(entity.isSeen, isTrue);
      expect(entity.createdAt.toUtc(), DateTime.utc(2026, 7, 13, 11, 0, 9));
    });

    test('builds an absolute image url from the relative path', () {
      final entity = TextNewsModel.fromJson({
        'id': 1,
        'title': 't',
        'image': 'news/1.png',
      }).toEntity();

      expect(entity.imageUrl, 'https://rozgaradda.com/news/1.png');
      expect(entity.categoryName, '');
    });
  });

  group('VideoNewsModel', () {
    test('accepts the legacy `subject` + relative `video` shape', () {
      final json =
          jsonDecode('''
        {
          "id": 4,
          "title": "Test",
          "subject": "Test subject",
          "video": "videos/1773694090.mp4",
          "added_by": 4,
          "status": "approved",
          "created_at": "2026-03-16 20:48:10"
        }
      ''')
              as Map<String, dynamic>;

      final entity = VideoNewsModel.fromJson(json).toEntity();

      expect(entity.description, 'Test subject');
      expect(entity.videoUrl, 'https://rozgaradda.com/videos/1773694090.mp4');
      expect(entity.videoPath, 'videos/1773694090.mp4');
      expect(entity.thumbnailUrl, '');
    });

    test('prefers absolute `video_url` and nested category/state', () {
      final entity = VideoNewsModel.fromJson({
        'id': 9,
        'title': 'T',
        'description': 'D',
        'video': 'videos/9.mp4',
        'video_url': 'https://rozgaradda.com/videos/9.mp4',
        'category': {'id': 12, 'name': 'Sports', 'slug': 'sports'},
        'state': {'id': 3, 'name': 'Uttar Pradesh'},
      }).toEntity();

      expect(entity.videoUrl, 'https://rozgaradda.com/videos/9.mp4');
      expect(entity.categoryId, 12);
      expect(entity.categoryName, 'Sports');
      expect(entity.stateId, 3);
      expect(entity.stateName, 'Uttar Pradesh');
    });
  });

  group('PaginationModel', () {
    test('parses the pagination block', () {
      final json =
          jsonDecode(
                '{"current_page":1,"per_page":3,"total":4,"last_page":2,"from":1,"to":3}',
              )
              as Map<String, dynamic>;

      final entity = PaginationModel.fromJson(json).toEntity();

      expect(entity.currentPage, 1);
      expect(entity.lastPage, 2);
      expect(entity.total, 4);
      expect(entity.hasMore, isTrue);
    });

    test('treats a missing pagination block as a single complete page', () {
      final entity = PaginationModel.fromJson(null, itemCount: 5).toEntity();

      expect(entity.currentPage, 1);
      expect(entity.lastPage, 1);
      expect(entity.total, 5);
      expect(entity.hasMore, isFalse);
    });

    test('parses string numbers', () {
      final entity = PaginationModel.fromJson({
        'current_page': '2',
        'per_page': '10',
        'total': '25',
        'last_page': '3',
      }).toEntity();

      expect(entity.currentPage, 2);
      expect(entity.lastPage, 3);
      expect(entity.hasMore, isTrue);
    });
  });
}
