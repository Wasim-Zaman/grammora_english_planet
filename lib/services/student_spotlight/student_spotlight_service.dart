import '../../models/paginated_result.dart';
import '../../models/student_spotlight.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentSpotlightService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _table = 'student_spotlights';

  /// Realtime stream of all spotlight records ordered by creation date
  Stream<List<StudentSpotlightModel>> getSpotlightsStream() {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) {
          return rows
              .map(
                (row) => StudentSpotlightModel.fromMap(
                  row,
                  row['id'].toString(),
                ),
              )
              .toList();
        });
  }

  /// Realtime stream of featured spotlights for user dashboard
  Stream<List<StudentSpotlightModel>> getFeaturedSpotlightsStream() {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('is_featured', true)
        .order('created_at', ascending: false)
        .map((rows) {
          return rows
              .map(
                (row) => StudentSpotlightModel.fromMap(
                  row,
                  row['id'].toString(),
                ),
              )
              .toList();
        });
  }

  /// Paginated query for admin and full list views
  Future<PaginatedResult<StudentSpotlightModel>> getSpotlightsPaginated({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? awardFilter,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize;

    var query = _supabase.from(_table).select();

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = searchQuery.trim();
      query = query.or('student_name.ilike.%$term%,course_or_batch.ilike.%$term%,period.ilike.%$term%');
    }

    if (awardFilter != null && awardFilter.isNotEmpty && awardFilter != 'All') {
      query = query.eq('award_title', awardFilter);
    }

    final data = await query
        .order('created_at', ascending: false)
        .range(from, to);

    final hasMore = data.length > pageSize;
    final items = (data as List)
        .take(pageSize)
        .map(
          (row) => StudentSpotlightModel.fromMap(
            row as Map<String, dynamic>,
            row['id'].toString(),
          ),
        )
        .toList();

    return PaginatedResult(items: items, hasMore: hasMore);
  }

  /// Fetch all active featured spotlights
  Future<List<StudentSpotlightModel>> getFeaturedSpotlights() async {
    final data = await _supabase
        .from(_table)
        .select()
        .eq('is_featured', true)
        .order('created_at', ascending: false);

    return (data as List)
        .map(
          (row) => StudentSpotlightModel.fromMap(
            row as Map<String, dynamic>,
            row['id'].toString(),
          ),
        )
        .toList();
  }

  /// Add a new spotlight
  Future<void> addSpotlight(StudentSpotlightModel spotlight) async {
    await _supabase.from(_table).insert(spotlight.toMap());
  }

  /// Update an existing spotlight
  Future<void> updateSpotlight(
    String id,
    StudentSpotlightModel spotlight,
  ) async {
    await _supabase.from(_table).update(spotlight.toMap()).eq('id', id);
  }

  /// Toggle featured status
  Future<void> toggleFeatured(String id, bool isFeatured) async {
    await _supabase
        .from(_table)
        .update({'is_featured': isFeatured})
        .eq('id', id);
  }

  /// Delete a spotlight record
  Future<void> deleteSpotlight(String id) async {
    await _supabase.from(_table).delete().eq('id', id);
  }
}
