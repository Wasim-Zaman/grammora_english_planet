import 'package:gep/models/shift/shift.dart';
import 'package:gep/models/paginated_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShiftsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _table = 'shifts';

  Future<PaginatedResult<Shift>> getShiftsPaginated({
    required int page,
    required int pageSize,
    String? searchQuery,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize;

    var query = _supabase.from(_table).select();
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('name', '%$searchQuery%');
    }

    final data = await query
        .order('created_at', ascending: false)
        .range(from, to);

    final hasMore = data.length > pageSize;
    final items = data
        .take(pageSize)
        .map((row) => Shift.fromMap(row, row['id'] as String))
        .toList();

    return PaginatedResult(items: items, hasMore: hasMore);
  }

  Future<List<Shift>> getAllShifts() async {
    final data = await _supabase.from(_table).select().order('created_at');
    return data.map((row) => Shift.fromMap(row, row['id'] as String)).toList();
  }

  Future<Shift> getShift(String id) async {
    final data = await _supabase.from(_table).select().eq('id', id).single();
    return Shift.fromMap(data, data['id'] as String);
  }

  Future<void> addShift(Shift shift) async {
    await _supabase.from(_table).insert(shift.toMap());
  }

  Future<void> updateShift(String id, Shift shift) async {
    await _supabase.from(_table).update(shift.toMap()).eq('id', id);
  }

  Future<void> deleteShift(String id) async {
    await _supabase.from(_table).delete().eq('id', id);
  }

  Future<List<String>> getStudentShiftIds(String studentId) async {
    final data = await _supabase
        .from('shift_students')
        .select('shift_id')
        .eq('student_id', studentId);
    return data.map((r) => r['shift_id'] as String).toList();
  }

  Future<void> assignStudentToShifts(
    String studentId,
    List<String> shiftIds,
  ) async {
    await _supabase.from('shift_students').delete().eq('student_id', studentId);
    if (shiftIds.isNotEmpty) {
      final rows = shiftIds
          .map((shiftId) => {'student_id': studentId, 'shift_id': shiftId})
          .toList();
      await _supabase.from('shift_students').insert(rows);
    }
  }
}
