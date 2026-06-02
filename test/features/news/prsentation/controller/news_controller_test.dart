import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/features/news/domain/entities/news_item.dart';
import 'package:rojgar/features/news/domain/repository/news_repository.dart';
import 'package:rojgar/features/news/prsentation/controller/news_controller.dart';

class FakeNewsRepository implements NewsRepository {
  Either<Failure, List<TextNews>> textNewsResult = const Right([]);
  Either<Failure, List<VideoNews>> videoNewsResult = const Right([]);
  Either<Failure, List<YoutubeNews>> youtubeNewsResult = const Right([]);

  @override
  Future<Either<Failure, List<TextNews>>> getTextNews() async => textNewsResult;

  @override
  Future<Either<Failure, List<VideoNews>>> getVideoNews() async => videoNewsResult;

  @override
  Future<Either<Failure, List<YoutubeNews>>> getYoutubeNews() async => youtubeNewsResult;
}

void main() {
  late NewsController controller;
  late FakeNewsRepository fakeRepository;

  final tTextNews = TextNews(
    id: 1,
    title: 'Text News Title',
    createdAt: DateTime(2026, 6, 2, 10, 0),
    category: 'Jobs',
    description: 'Job description text',
    imageUrl: 'http://image.jpg',
    imagePath: '/path/to/img',
    status: 'active',
    isSeen: false,
    addedBy: 1,
  );

  final tVideoNews = VideoNews(
    id: 2,
    title: 'Video News Title',
    createdAt: DateTime(2026, 6, 2, 11, 0),
    subject: 'Direct Upload Subject',
    videoUrl: 'http://video.mp4',
    videoPath: '/path/to/video',
    status: 'active',
    addedBy: 1,
  );

  final tYoutubeNews = YoutubeNews(
    id: 3,
    title: 'Youtube Video Title',
    createdAt: DateTime(2026, 6, 2, 12, 0),
    youtubeUrl: 'https://youtube.com/watch?v=123',
    description: 'Youtube video description',
    thumbnailUrl: 'http://yt-thumb.jpg',
    youtubeId: '123',
    updatedAt: DateTime(2026, 6, 2, 12, 0),
  );

  setUp(() {
    fakeRepository = FakeNewsRepository();
    // Use controller without auto-init in test or allow it to run and re-run manually.
    // By default, GetxController's onInit is called when registered, but we instantiate it directly here.
    controller = NewsController(repository: fakeRepository);
  });

  group('fetchNews', () {
    test('should assign loaded and sorted lists on success', () async {
      // Arrange
      fakeRepository.textNewsResult = Right([tTextNews]);
      fakeRepository.videoNewsResult = Right([tVideoNews]);
      fakeRepository.youtubeNewsResult = Right([tYoutubeNews]);

      // Act
      await controller.fetchNews();

      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, '');
      expect(controller.textNews.length, 1);
      expect(controller.textNews.first, tTextNews);
      
      // Video news tab list should contain both VideoNews and YoutubeNews sorted by date descending (YoutubeNews (12:00) first, then VideoNews (11:00))
      expect(controller.videoNews.length, 2);
      expect(controller.videoNews[0], tYoutubeNews);
      expect(controller.videoNews[1], tVideoNews);

      // All news list should contain all three items sorted by date descending (YoutubeNews (12:00) -> VideoNews (11:00) -> TextNews (10:00))
      expect(controller.allNews.length, 3);
      expect(controller.allNews[0], tYoutubeNews);
      expect(controller.allNews[1], tVideoNews);
      expect(controller.allNews[2], tTextNews);
    });

    test('should partial succeed when some APIs fail but others return data', () async {
      // Arrange
      fakeRepository.textNewsResult = Left(Failure('Failed to load text news'));
      fakeRepository.videoNewsResult = Right([tVideoNews]);
      fakeRepository.youtubeNewsResult = Right([tYoutubeNews]);

      // Act
      await controller.fetchNews();

      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, ''); // Should not set error because we got video data
      expect(controller.textNews.isEmpty, true);
      expect(controller.videoNews.length, 2);
      expect(controller.allNews.length, 2);
    });

    test('should set errorMessage on total failure (all APIs fail)', () async {
      // Arrange
      fakeRepository.textNewsResult = Left(Failure('API error 1'));
      fakeRepository.videoNewsResult = Left(Failure('API error 2'));
      fakeRepository.youtubeNewsResult = Left(Failure('API error 3'));

      // Act
      await controller.fetchNews();

      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'API error 1'); // Should take first error
      expect(controller.allNews.isEmpty, true);
      expect(controller.textNews.isEmpty, true);
      expect(controller.videoNews.isEmpty, true);
    });
  });
}
