import 'package:flutter/foundation.dart';
import 'package:rentify_mobile/models/search_result.dart';

typedef PagedFetcher<T> = Future<SearchResult<T>> Function({
  required int page,
  required int pageSize,
  String? filter,
  bool includeTotalCount,
});

class UniversalPagingProvider<T> with ChangeNotifier {
  final PagedFetcher<T> fetcher;
  final int pageSize;

  SearchResult<T> _result = SearchResult<T>();
  int _page = 0;
  bool _isLoading = false;
  String _filter = "";

  UniversalPagingProvider({required this.fetcher, this.pageSize = 5});

  List<T> get items => _result.items;
  int get page => _page;
  int get totalCount => _result.totalCount;
  bool get isLoading => _isLoading;

  bool get hasNextPage => (_page + 1) * pageSize < totalCount;
  bool get hasPreviousPage => _page > 0;

  Future<void> loadPage({int? pageNumber, String? filter}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    if (pageNumber != null) _page = pageNumber;
    if (filter != null) _filter = filter;

    try {
      final result = await fetcher(
        page: _page,
        pageSize: pageSize,
        filter: _filter.isNotEmpty ? _filter : null,
        includeTotalCount: true, 
      );
      _result = result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> nextPage() async {
    if (hasNextPage) {
      _page++;
      await loadPage();
    }
  }

  Future<void> previousPage() async {
    if (hasPreviousPage) {
      _page--;
      await loadPage();
    }
  }

  Future<void> refresh() async {
    await loadPage();
  }

  Future<void> goToPage(int pageNumber, String value) async {
    if (pageNumber >= 0 && pageNumber * pageSize < totalCount) {
      _page = pageNumber;
      await loadPage(filter: value);
    }
  }

  Future<void> search(String filter) async {
    _page = 0;
    await loadPage(filter: filter);
  }

  void clear() {
    _result.clear();
    _page = 0;
    _filter = "";
    notifyListeners();
  }
}
