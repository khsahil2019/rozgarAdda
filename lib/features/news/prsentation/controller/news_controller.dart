import 'package:get/get.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/repository/news_repository.dart';

class NewsController extends GetxController {
  final NewsRepository repository;

  NewsController({required this.repository});

  final RxList<NewsItem> allNews = <NewsItem>[].obs;
  final RxList<TextNews> textNews = <TextNews>[].obs;
  final RxList<NewsItem> videoNews = <NewsItem>[].obs; // Contains both VideoNews and YoutubeNews
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt activeTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNews();
  }

  Future<void> fetchNews() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    // Fetch all three concurrently
    final results = await Future.wait([
      repository.getTextNews(),
      repository.getVideoNews(),
      repository.getYoutubeNews(),
    ]);

    final textResult = results[0];
    final videoResult = results[1];
    final youtubeResult = results[2];

    List<TextNews> fetchedTextNews = [];
    List<VideoNews> fetchedVideoNews = [];
    List<YoutubeNews> fetchedYoutubeNews = [];
    String? error;

    textResult.fold(
      (failure) => error = failure.message,
      (list) => fetchedTextNews = List<TextNews>.from(list),
    );

    videoResult.fold(
      (failure) => error ??= failure.message,
      (list) => fetchedVideoNews = List<VideoNews>.from(list),
    );

    youtubeResult.fold(
      (failure) => error ??= failure.message,
      (list) => fetchedYoutubeNews = List<YoutubeNews>.from(list),
    );

    if (error != null && fetchedTextNews.isEmpty && fetchedVideoNews.isEmpty && fetchedYoutubeNews.isEmpty) {
      errorMessage.value = error!;
    } else {
      textNews.assignAll(fetchedTextNews);
      
      final List<NewsItem> combinedVideos = [
        ...fetchedVideoNews,
        ...fetchedYoutubeNews,
      ];
      // Sort videos by date descending
      combinedVideos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      videoNews.assignAll(combinedVideos);

      final List<NewsItem> combinedAll = [
        ...fetchedTextNews,
        ...fetchedVideoNews,
        ...fetchedYoutubeNews,
      ];
      // Sort all news by date descending
      combinedAll.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      allNews.assignAll(combinedAll);
    }
    
    isLoading.value = false;
  }
}
