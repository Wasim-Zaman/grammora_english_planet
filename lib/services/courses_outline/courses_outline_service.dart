import 'package:gep/models/course_outline.dart';
import 'package:gep/models/paginated_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoursesOutlineService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _table = 'courses_outlines';

  Stream<List<Course>> getCoursesStream() {
    return _supabase.from(_table).stream(primaryKey: ['id']).map((rows) {
      return rows.map((row) => _mapCourse(row)).toList();
    });
  }

  Future<PaginatedResult<Course>> getCoursesPaginated({
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

    final data = await query.order('id', ascending: false).range(from, to);

    final hasMore = data.length > pageSize;
    final items = data.take(pageSize).map((row) => _mapCourse(row)).toList();

    return PaginatedResult(items: items, hasMore: hasMore);
  }

  Course _mapCourse(Map<String, dynamic> row) {
    List<Week> weeks = ((row['weeks'] as List?) ?? []).map((weekData) {
      return Week(
        title: weekData['title'],
        topics: List<String>.from(weekData['topics'] ?? []),
      );
    }).toList();

    return Course(
      id: row['id'] as String,
      title: row['title'],
      weeks: weeks,
    );
  }

  Future<void> addCourse(Course course) async {
    await _supabase.from(_table).insert(_toRow(course));
  }

  Future<void> updateCourse(String courseId, Course course) async {
    await _supabase.from(_table).update(_toRow(course)).eq('id', courseId);
  }

  Future<void> deleteCourse(String courseId) async {
    await _supabase.from(_table).delete().eq('id', courseId);
  }

  Map<String, dynamic> _toRow(Course course) => {
        'title': course.title,
        'weeks': course.weeks
            .map((week) => {
                  'title': week.title,
                  'topics': week.topics,
                })
            .toList(),
      };
}
