/// Result wrapper for a single paginated fetch.
class PaginatedResult<T> {
  final List<T> items;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    required this.hasMore,
  });
}
