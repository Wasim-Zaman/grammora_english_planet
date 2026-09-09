import 'package:gep/models/admission_announcement.dart';
import 'package:gep/models/paginated_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdmissionsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _table = 'admission_announcements';

  // Create
  Future<void> addAnnouncement(AdmissionAnnouncement announcement) async {
    try {
      await _supabase.from(_table).insert(_toRow(announcement));
    } catch (e) {
      throw Exception('Failed to add announcement: $e');
    }
  }

  // Read
  Stream<List<AdmissionAnnouncement>> getAnnouncementsStream() {
    return _supabase.from(_table).stream(primaryKey: ['id']).map((rows) {
      return rows
          .map((row) => AdmissionAnnouncement.fromMap({
                'id': row['id'],
                'title': row['title'],
                'startDate': row['start_date'],
                'endDate': row['end_date'],
                'details': row['details'],
              }))
          .toList();
    });
  }

  Future<PaginatedResult<AdmissionAnnouncement>> getAnnouncementsPaginated({
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

    final data = await query.order('start_date', ascending: false).range(from, to);

    final hasMore = data.length > pageSize;
    final items = data
        .take(pageSize)
        .map((row) => AdmissionAnnouncement.fromMap({
              'id': row['id'],
              'title': row['title'],
              'startDate': row['start_date'],
              'endDate': row['end_date'],
              'details': row['details'],
            }))
        .toList();

    return PaginatedResult(items: items, hasMore: hasMore);
  }

  // Update
  Future<void> updateAnnouncement(AdmissionAnnouncement announcement) async {
    try {
      await _supabase
          .from(_table)
          .update(_toRow(announcement))
          .eq('id', announcement.id);
    } catch (e) {
      throw Exception('Failed to update announcement: $e');
    }
  }

  // Delete
  Future<void> deleteAnnouncement(String id) async {
    try {
      await _supabase.from(_table).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete announcement: $e');
    }
  }

  Map<String, dynamic> _toRow(AdmissionAnnouncement announcement) => {
        'title': announcement.title,
        'start_date': announcement.startDate.toIso8601String(),
        'end_date': announcement.endDate.toIso8601String(),
        'details': announcement.details,
      };
}
