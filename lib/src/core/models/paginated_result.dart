/// A generic page of results plus everything a caller needs to fetch the
/// next one. `nextOffset` is only meaningful when [hasMore] is true.
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.hasMore,
    required this.nextOffset,
  });

  final List<T> items;
  final bool hasMore;
  final int nextOffset;

  PaginatedResult<T> copyWith({List<T>? items, bool? hasMore, int? nextOffset}) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      nextOffset: nextOffset ?? this.nextOffset,
    );
  }
}
