/// A page of a P2P list: `{count, next, results}`, where [next] is the next
/// page's number or null on the last page. `?page=` picks a page and
/// `?limit=` its size (30 by default, at most 100).
class P2pPage<T> {
  /// The most a page can hold.
  static const int maxLimit = 100;

  final int count;
  final int? next;
  final List<T> results;

  const P2pPage({
    required this.count,
    required this.next,
    required this.results,
  });

  /// Throws a [FormatException] when [json] has no `results` list.
  factory P2pPage.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic> json) item) {
    final results = json['results'];
    if (results is! List) {
      throw const FormatException('A P2P list has no results');
    }
    final count = json['count'];
    final next = json['next'];
    return P2pPage<T>(
      count: count is int ? count : results.length,
      next: next is int ? next : null,
      results: results.whereType<Map<String, dynamic>>().map(item).toList(),
    );
  }

  bool get hasNext => next != null;
}

/// Every item of a paged list: reads page after page with [read] until the
/// registry says there is no next one. [maxPages] bounds the reads, far
/// above what any shop should hold.
Future<List<T>> p2pReadAllPages<T>(Future<P2pPage<T>> Function(int page) read, {int maxPages = 20}) async {
  final items = <T>[];
  int? page = 1;
  for (var reads = 0; page != null && reads < maxPages; reads++) {
    final result = await read(page);
    items.addAll(result.results);
    page = result.next;
  }
  return items;
}
