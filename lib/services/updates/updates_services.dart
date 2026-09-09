import 'package:gep/models/paginated_result.dart';
import 'package:gep/models/updates.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdatesServices {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _table = 'updates';

  Stream<List<Updates>> getUpdatesStream() {
    return _supabase.from(_table).stream(primaryKey: ['id']).map((rows) {
      final updates = rows
          .map((row) => Updates.fromMap(row, row['id'] as String))
          .toList();
      updates.sort((a, b) => b.date.compareTo(a.date));
      return updates;
    });
  }

  Future<PaginatedResult<Updates>> getUpdatesPaginated({
    required int page,
    required int pageSize,
    String? searchQuery,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize;

    var query = _supabase.from(_table).select();
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('title', '%$searchQuery%');
    }

    final data = await query
        .order('timestamp', ascending: false)
        .range(from, to);

    final hasMore = data.length > pageSize;
    final items = data
        .take(pageSize)
        .map((row) => Updates.fromMap(row, row['id'] as String))
        .toList();

    return PaginatedResult(items: items, hasMore: hasMore);
  }

  Future<void> addUpdate(Updates update) async {
    await _supabase.from(_table).insert(update.toMap());
  }

  Future<void> updateUpdate(String updateId, Updates update) async {
    await _supabase.from(_table).update(update.toMap()).eq('id', updateId);
  }

  Future<void> deleteUpdate(String updateId) async {
    await _supabase.from(_table).delete().eq('id', updateId);
  }
}
