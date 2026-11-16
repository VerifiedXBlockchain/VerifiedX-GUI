/// A page of a P2P list: `{count, next, results}`, where [next] is the next
/// page's number or null on the last page. `?page=` picks a page and
/// `?limit=` its size (30 by default, at most 100).
class P2pPage<T> {
  static const int defaultLimit = 30;
  static const int maxLimit = 100;

  final int count;
  final int? next;
  final List<T> results;

  const P2pPage({
    required this.count,
    required this.next,
    required this.results,
  });

  factory P2pPage.empty() => P2pPage<T>(count: 0, next: null, results: const []);

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
