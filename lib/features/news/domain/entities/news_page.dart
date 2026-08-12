class NewsPagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const NewsPagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;
}

/// One page of a paginated news listing.
class NewsPage<T> {
  final List<T> items;
  final NewsPagination pagination;

  const NewsPage({required this.items, required this.pagination});
}
