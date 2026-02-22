class SearchResult<T> {
  int totalCount;
  List<T> items;

  SearchResult({
    this.totalCount = 0,
    List<T>? items,
  }) : items = items ?? [];

  void clear() {
    totalCount = 0;
    items.clear();
  }

  void add(T value) {
    items.add(value);
    totalCount = items.length;
  }
}
