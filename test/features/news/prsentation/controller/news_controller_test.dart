import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/features/news/domain/entities/news_category.dart';
import 'package:rojgar/features/news/domain/entities/news_item.dart';
import 'package:rojgar/features/news/domain/entities/news_page.dart';
import 'package:rojgar/features/news/domain/entities/news_state.dart';
import 'package:rojgar/features/news/domain/repository/news_repository.dart';
import 'package:rojgar/features/news/prsentation/controller/news_controller.dart';

NewsPage<T> _page<T>(List<T> items, {int currentPage = 1, int lastPage = 1}) {
  return NewsPage<T>(
    items: items,
    pagination: NewsPagination(
      currentPage: currentPage,
      perPage: 10,
      total: items.length,
      lastPage: lastPage,
    ),
  );
}

class FakeNewsRepository implements NewsRepository {
  Either<Failure, List<NewsCategory>> categoriesResult = const Right([
    NewsCategory(id: 7, name: 'National News', slug: 'national-news'),
    NewsCategory(id: 12, name: 'Sports', slug: 'sports'),
  ]);
  Either<Failure, List<NewsState>> statesResult = const Right([
    NewsState(id: 28, name: 'West Bengal'),
    NewsState(id: 3, name: 'Uttar Pradesh'),
  ]);

  /// Results served per requested page, keyed by page number.
  Map<int, Either<Failure, NewsPage<TextNews>>> textPages = {};
  Map<int, Either<Failure, NewsPage<VideoNews>>> videoPages = {};

  final List<String> createdNews = [];
  int? lastTextCategoryId;
  int? lastTextStateId;

  @override
  Future<Either<Failure, List<NewsCategory>>> getCategories() async =>
      categoriesResult;

  @override
  Future<Either<Failure, List<NewsState>>> getStates() async => statesResult;

  @override
  Future<Either<Failure, NewsPage<TextNews>>> getTextNews({
    required int categoryId,
    required int stateId,
    int page = 1,
    int perPage = 10,
  }) async {
    lastTextCategoryId = categoryId;
    lastTextStateId = stateId;
    return textPages[page] ?? Right(_page<TextNews>(const []));
  }

  @override
  Future<Either<Failure, NewsPage<VideoNews>>> getVideoNews({
    required int categoryId,
    required int stateId,
    int page = 1,
    int perPage = 10,
  }) async {
    return videoPages[page] ?? Right(_page<VideoNews>(const []));
  }

  @override
  Future<Either<Failure, String>> createNews({
    required int categoryId,
    required int stateId,
    required String title,
    required String description,
    String? imagePath,
  }) async {
    createdNews.add(title);
    return const Right('ok');
  }
}

void main() {
  late NewsController controller;
  late FakeNewsRepository fakeRepository;

  TextNews textNews({required int id, required DateTime createdAt}) => TextNews(
    id: id,
    title: 'Text News $id',
    createdAt: createdAt,
    categoryId: 7,
    stateId: 28,
    categoryName: 'National News',
    stateName: 'West Bengal',
    description: 'Description $id',
    imageUrl: 'https://rozgaradda.com/news/$id.png',
    imagePath: 'news/$id.png',
    status: 'approved',
    isSeen: true,
    addedBy: 11,
  );

  VideoNews videoNews({required int id, required DateTime createdAt}) =>
      VideoNews(
        id: id,
        title: 'Video News $id',
        createdAt: createdAt,
        categoryId: 7,
        stateId: 28,
        categoryName: 'National News',
        stateName: 'West Bengal',
        description: 'Video description $id',
        videoUrl: 'https://rozgaradda.com/videos/$id.mp4',
        videoPath: 'videos/$id.mp4',
        thumbnailUrl: '',
        addedBy: 11,
        status: 'approved',
      );

  setUp(() {
    fakeRepository = FakeNewsRepository();
    controller = NewsController(repository: fakeRepository);
  });

  group('bootstrap', () {
    test(
      'loads filters, defaults the selection and fetches the feed',
      () async {
        final article = textNews(id: 1, createdAt: DateTime(2026, 8, 1, 10));
        final video = videoNews(id: 2, createdAt: DateTime(2026, 8, 1, 11));
        fakeRepository.textPages = {
          1: Right(_page([article])),
        };
        fakeRepository.videoPages = {
          1: Right(_page([video])),
        };

        await controller.bootstrap();

        expect(controller.categories.length, 2);
        expect(controller.states.length, 2);
        // Falls back to the first category/state when nothing is saved.
        expect(controller.selectedCategoryId.value, 7);
        expect(controller.selectedStateId.value, 28);
        expect(fakeRepository.lastTextCategoryId, 7);
        expect(fakeRepository.lastTextStateId, 28);
        expect(controller.isLoading.value, false);
        expect(controller.errorMessage.value, '');
        // Newest first.
        expect(controller.allNews.map((e) => e.id), [2, 1]);
        expect(controller.textNews.length, 1);
        expect(controller.videoNews.length, 1);
      },
    );

    test('reports an error when the filters cannot be loaded', () async {
      fakeRepository.categoriesResult = Left(Failure('no categories'));

      await controller.bootstrap();

      expect(controller.errorMessage.value, 'no categories');
      expect(controller.isLoading.value, false);
    });
  });

  group('fetchNews', () {
    setUp(() async {
      await controller.bootstrap();
    });

    test('keeps the feed when only one listing fails', () async {
      fakeRepository.textPages = {1: Left(Failure('text down'))};
      fakeRepository.videoPages = {
        1: Right(_page([videoNews(id: 5, createdAt: DateTime(2026, 8, 2))])),
      };

      await controller.fetchNews();

      expect(controller.errorMessage.value, '');
      expect(controller.textNews, isEmpty);
      expect(controller.videoNews.length, 1);
      expect(controller.allNews.length, 1);
    });

    test('sets errorMessage when every listing fails', () async {
      fakeRepository.textPages = {1: Left(Failure('text down'))};
      fakeRepository.videoPages = {1: Left(Failure('video down'))};

      await controller.fetchNews();

      expect(controller.errorMessage.value, 'text down');
      expect(controller.allNews, isEmpty);
    });

    test('refetches with the newly selected category', () async {
      controller.selectCategory(12);
      await Future<void>.delayed(Duration.zero);

      expect(controller.selectedCategoryId.value, 12);
      expect(fakeRepository.lastTextCategoryId, 12);
    });
  });

  group('loadMore', () {
    test('appends the next page and stops at the last page', () async {
      fakeRepository.textPages = {
        1: Right(
          _page(
            [textNews(id: 1, createdAt: DateTime(2026, 8, 3))],
            currentPage: 1,
            lastPage: 2,
          ),
        ),
        2: Right(
          _page(
            [textNews(id: 2, createdAt: DateTime(2026, 8, 2))],
            currentPage: 2,
            lastPage: 2,
          ),
        ),
      };

      await controller.bootstrap();
      expect(controller.textNews.length, 1);
      expect(controller.hasMore, isTrue);

      await controller.loadMore();

      expect(controller.textNews.map((e) => e.id), [1, 2]);
      expect(controller.hasMore, isFalse);

      // No further requests once the last page is reached.
      await controller.loadMore();
      expect(controller.textNews.length, 2);
    });

    test(
      'only pages the articles list while the articles tab is active',
      () async {
        fakeRepository.textPages = {
          1: Right(
            _page([
              textNews(id: 1, createdAt: DateTime(2026, 8, 3)),
            ], lastPage: 2),
          ),
          2: Right(
            _page(
              [textNews(id: 2, createdAt: DateTime(2026, 8, 2))],
              currentPage: 2,
              lastPage: 2,
            ),
          ),
        };
        fakeRepository.videoPages = {
          1: Right(
            _page([
              videoNews(id: 3, createdAt: DateTime(2026, 8, 4)),
            ], lastPage: 2),
          ),
          2: Right(
            _page(
              [videoNews(id: 4, createdAt: DateTime(2026, 8, 1))],
              currentPage: 2,
              lastPage: 2,
            ),
          ),
        };

        await controller.bootstrap();
        controller.selectTab(NewsTab.articles);
        await controller.loadMore();

        expect(controller.textNews.length, 2);
        expect(controller.videoNews.length, 1);
      },
    );
  });
}
