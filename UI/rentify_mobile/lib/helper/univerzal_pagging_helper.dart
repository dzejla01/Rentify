import 'package:flutter/foundation.dart';
import 'package:rentify_mobile/models/search_result.dart';

typedef PagedFetcher<T> =
    Future<SearchResult<T>> Function({
      required int page,
      required int pageSize,
      String? filter,
      Map<String, dynamic>? extra,
      bool includeTotalCount,
    });

class UniversalPagingProvider<T> with ChangeNotifier {
  final PagedFetcher<T> fetcher;
  final int pageSize;

  SearchResult<T> _result = SearchResult<T>();
  int _page = 0;
  bool _isLoading = false;
  String _filter = "";
  String? _error;

  UniversalPagingProvider({required this.fetcher, this.pageSize = 5});

  List<T> get items => _result.items;
  int get page => _page;
  int get totalCount => _result.totalCount;
  bool get isLoading => _isLoading;

  String get filter => _filter;
  String? get error => _error;

  bool get hasNextPage => (_page + 1) * pageSize < totalCount;
  bool get hasPreviousPage => _page > 0;

  int get totalPages =>
      totalCount == 0 ? 1 : ((totalCount + pageSize - 1) ~/ pageSize);

  Map<String, dynamic> _extra = {};
  Map<String, dynamic> get extra => _extra;

  Future<void> loadPage({int? pageNumber, String? filter}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    if (pageNumber != null) _page = pageNumber;
    if (filter != null) _filter = filter;

    try {
      final result = await fetcher(
        page: _page,
        pageSize: pageSize,
        filter: _filter.isNotEmpty ? _filter : null,
        extra: _extra,
        includeTotalCount: true,
      );
      _result = result;
    } catch (e) {
      _error = e.toString();
      _result.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyExtra(Map<String, dynamic> extra) async {
    _extra = extra;
    _page = 0;
    await loadPage();
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

  Future<void> refresh() async => loadPage();

  Future<void> search(String filter) async {
    _page = 0;
    await loadPage(filter: filter);
  }

  void clear() {
    _result.clear();
    _page = 0;
    _filter = "";
    _error = null;
    notifyListeners();
  }
}
