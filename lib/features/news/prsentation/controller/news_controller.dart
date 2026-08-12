import 'package:get/get.dart';
import 'package:rojgar/features/app/app_controller.dart';
import '../../domain/entities/news_category.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/entities/news_state.dart';
import '../../domain/repository/news_repository.dart';

/// Tabs of the news feed.
enum NewsTab { all, articles, videos }

class NewsController extends GetxController {
  final NewsRepository repository;

  NewsController({required this.repository});

  static const int _perPage = 10;

  // Filters
  final RxList<NewsCategory> categories = <NewsCategory>[].obs;
  final RxList<NewsState> states = <NewsState>[].obs;
  final RxnInt selectedCategoryId = RxnInt();
  final RxnInt selectedStateId = RxnInt();

  // Feed
  final RxList<TextNews> textNews = <TextNews>[].obs;
  final RxList<VideoNews> videoNews = <VideoNews>[].obs;
  final RxList<NewsItem> allNews = <NewsItem>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<NewsTab> activeTab = NewsTab.all.obs;

  int _textPage = 0;
  int _textLastPage = 1;
  int _videoPage = 0;
  int _videoLastPage = 1;

  @override
  void onInit() {
    super.onInit();
    bootstrap();
  }

  NewsCategory? get selectedCategory =>
      categories.firstWhereOrNull((c) => c.id == selectedCategoryId.value);

  NewsState? get selectedState =>
      states.firstWhereOrNull((s) => s.id == selectedStateId.value);

  List<NewsItem> get currentList => switch (activeTab.value) {
    NewsTab.all => allNews,
    NewsTab.articles => textNews,
    NewsTab.videos => videoNews,
  };

  bool get hasMore => switch (activeTab.value) {
    NewsTab.all => _textPage < _textLastPage || _videoPage < _videoLastPage,
    NewsTab.articles => _textPage < _textLastPage,
    NewsTab.videos => _videoPage < _videoLastPage,
  };

  /// Loads the filter options, then the first page of the feed.
  Future<void> bootstrap() async {
    isLoading.value = true;
    errorMessage.value = '';

    final categoriesFuture = repository.getCategories();
    final statesFuture = repository.getStates();

    String? error;

    (await categoriesFuture).fold(
      (failure) => error = failure.message,
      (list) => categories.assignAll(list),
    );
    (await statesFuture).fold(
      (failure) => error ??= failure.message,
      (list) => states.assignAll(list),
    );

    if (categories.isEmpty || states.isEmpty) {
      errorMessage.value = error ?? 'Unable to load news filters.';
      isLoading.value = false;
      return;
    }

    selectedCategoryId.value ??= categories.first.id;
    selectedStateId.value ??= _resolveDefaultStateId();

    await fetchNews();
  }

  /// The app-wide state selection uses a different id space (`/api/states-images`),
  /// so the news state is resolved by matching on name, falling back to the
  /// first available state.
  int _resolveDefaultStateId() {
    final savedName = Get.isRegistered<AppController>()
        ? AppController.to.selectedStateName
        : null;
    if (savedName != null && savedName.trim().isNotEmpty) {
      final match = _matchStateByName(savedName);
      if (match != null) return match.id;
    }
    return states.first.id;
  }

  NewsState? _matchStateByName(String name) {
    final target = _normalizeStateName(name);
    if (target.isEmpty) return null;

    final exact = states.firstWhereOrNull(
      (s) => _normalizeStateName(s.name) == target,
    );
    if (exact != null) return exact;

    // "Ladakh" vs "Laddakh" and similar spelling variants.
    final collapsed = _collapseRepeats(target);
    final byCollapsed = states.firstWhereOrNull(
      (s) => _collapseRepeats(_normalizeStateName(s.name)) == collapsed,
    );
    if (byCollapsed != null) return byCollapsed;

    // "Gujarati, Hindi" -> "Gujarat", "Daman Diu" -> "Daman and Diu".
    return states.firstWhereOrNull((s) {
      final candidate = _normalizeStateName(s.name);
      if (candidate.isEmpty) return false;
      return candidate.startsWith(target) ||
          target.startsWith(candidate) ||
          _shareAllWords(s.name, name);
    });
  }

  static String _normalizeStateName(String value) => value
      .toLowerCase()
      .replaceAll('&', 'and')
      .replaceAll(RegExp(r'[^a-z0-9]'), '');

  static String _collapseRepeats(String value) {
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      if (i == 0 || value[i] != value[i - 1]) buffer.write(value[i]);
    }
    return buffer.toString();
  }

  static bool _shareAllWords(String a, String b) {
    Set<String> words(String value) => value
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.isNotEmpty && w != 'and')
        .toSet();
    final wa = words(a);
    final wb = words(b);
    if (wa.isEmpty || wb.isEmpty) return false;
    return wa.containsAll(wb) || wb.containsAll(wa);
  }

  void selectCategory(int categoryId) {
    if (selectedCategoryId.value == categoryId) return;
    selectedCategoryId.value = categoryId;
    fetchNews();
  }

  void selectState(int stateId) {
    if (selectedStateId.value == stateId) return;
    selectedStateId.value = stateId;
    fetchNews();
  }

  void selectTab(NewsTab tab) => activeTab.value = tab;

  /// Reloads the first page for the current filters.
  Future<void> fetchNews() async {
    final categoryId = selectedCategoryId.value;
    final stateId = selectedStateId.value;
    if (categoryId == null || stateId == null) {
      await bootstrap();
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    _textPage = 0;
    _videoPage = 0;
    _textLastPage = 1;
    _videoLastPage = 1;

    final error = await _loadPage(
      categoryId: categoryId,
      stateId: stateId,
      append: false,
    );

    if (error != null && textNews.isEmpty && videoNews.isEmpty) {
      errorMessage.value = error;
    }
    isLoading.value = false;
  }

  /// Loads the next page for the active tab.
  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore) return;
    final categoryId = selectedCategoryId.value;
    final stateId = selectedStateId.value;
    if (categoryId == null || stateId == null) return;

    isLoadingMore.value = true;
    await _loadPage(categoryId: categoryId, stateId: stateId, append: true);
    isLoadingMore.value = false;
  }

  /// Fetches the next page of each list the active tab needs and merges it in.
  /// Returns an error message when every requested list failed.
  Future<String?> _loadPage({
    required int categoryId,
    required int stateId,
    required bool append,
  }) async {
    final tab = activeTab.value;
    final wantsText = !append || tab != NewsTab.videos;
    final wantsVideo = !append || tab != NewsTab.articles;

    final loadText = wantsText && (!append || _textPage < _textLastPage);
    final loadVideo = wantsVideo && (!append || _videoPage < _videoLastPage);

    final errors = <String>[];
    var succeeded = 0;

    await Future.wait([
      if (loadText)
        repository
            .getTextNews(
              categoryId: categoryId,
              stateId: stateId,
              page: _textPage + 1,
              perPage: _perPage,
            )
            .then((result) {
              result.fold((failure) => errors.add(failure.message), (page) {
                succeeded++;
                _textPage = page.pagination.currentPage;
                _textLastPage = page.pagination.lastPage;
                if (append) {
                  textNews.addAll(page.items);
                } else {
                  textNews.assignAll(page.items);
                }
              });
            }),
      if (loadVideo)
        repository
            .getVideoNews(
              categoryId: categoryId,
              stateId: stateId,
              page: _videoPage + 1,
              perPage: _perPage,
            )
            .then((result) {
              result.fold((failure) => errors.add(failure.message), (page) {
                succeeded++;
                _videoPage = page.pagination.currentPage;
                _videoLastPage = page.pagination.lastPage;
                if (append) {
                  videoNews.addAll(page.items);
                } else {
                  videoNews.assignAll(page.items);
                }
              });
            }),
    ]);

    _rebuildAllNews();

    return succeeded == 0 && errors.isNotEmpty ? errors.first : null;
  }

  void _rebuildAllNews() {
    final combined = <NewsItem>[...textNews, ...videoNews]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    allNews.assignAll(combined);
  }
}
