import 'dart:developer';

import 'package:gep/models/enrolled_students.dart';
import 'package:gep/models/paginated_result.dart';
import 'package:gep/services/analytics/analytics_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EnrolledStudentsServices {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _table = 'enrolled_students';
  final AnalyticsService _analyticsService;

  EnrolledStudentsServices(this._analyticsService);

  Stream<List<EnrolledStudent>> getEnrolledStudentsStream() {
    return _supabase.from(_table).stream(primaryKey: ['id']).map((rows) {
      final students = rows.map((row) {
        final id = row['id']?.toString() ?? '';
        return _fromRow(row, id);
      }).toList();
      students.sort((a, b) => a.name.compareTo(b.name));
      return students;
    });
  }

  Future<PaginatedResult<EnrolledStudent>> getStudentsPaginated({
    required int page,
    required int pageSize,
    String? searchQuery,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize;

    var query = _supabase.from(_table).select();
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('name.ilike.%$searchQuery%,email.ilike.%$searchQuery%');
    }

    final data = await query.order('name', ascending: true).range(from, to);

    final hasMore = data.length > pageSize;
    final items = data
        .take(pageSize)
        .map((row) => _fromRow(row, row['id']?.toString() ?? ''))
        .toList();

    return PaginatedResult(items: items, hasMore: hasMore);
  }

  Future<void> addStudent(EnrolledStudent student) async {
    try {
      await _supabase.from(_table).insert(_toRow(student));

      // Log the student enrollment
      await _analyticsService.logStudentEnrollment(
        student.name,
        student.fatherName,
      );
    } catch (e) {
      log('Error adding student: $e');
      rethrow;
    }
  }

  Future<void> updateStudent(String studentId, EnrolledStudent student) async {
    try {
      await _supabase.from(_table).update(_toRow(student)).eq('id', studentId);

      // Log the student update
      await _analyticsService.logStudentUpdate(
        student.name,
        student.fatherName,
      );
    } catch (e) {
      log('Error updating student: $e');
      rethrow;
    }
  }

  Future<void> deleteStudent(String studentId) async {
    try {
      // Get the student data before deletion
      final studentData = await _supabase
          .from(_table)
          .select('name, father_name')
          .eq('id', studentId)
          .single();

      // Delete the student
      await _supabase.from(_table).delete().eq('id', studentId);

      // Log the student deletion
      await _analyticsService.logStudentDeletion(
        studentData['name'] as String,
        studentData['father_name'] as String,
      );
    } catch (e) {
      log('Error deleting student: $e');
      rethrow;
    }
  }

  Future<EnrolledStudent?> getStudentById(String studentId) async {
    final data = await _supabase
        .from(_table)
        .select()
        .eq('id', studentId)
        .maybeSingle();
    if (data != null) {
      return _fromRow(data, data['id'] as String);
    }
    return null;
  }

  Future<List<EnrolledStudent>> getEnrolledStudentsByEmail(String email) async {
    final data = await _supabase.from(_table).select().eq('email', email);
    return data.map((row) => _fromRow(row, row['id'] as String)).toList();
  }

  Future<List<EnrolledStudent>> getStudentsByLevel(String level) async {
    final data = await _supabase.from(_table).select().eq('level', level);
    return data.map((row) => _fromRow(row, row['id'] as String)).toList();
  }

  Future<int> getTotalStudents() async {
    final response = await _supabase
        .from(_table)
        .select()
        .count(CountOption.exact);
    return response.count;
  }

  Future<List<EnrolledStudent>> getStudentsByYear(int year) async {
    final data = await _supabase
        .from(_table)
        .select()
        .gte('enrollment_date', DateTime(year, 1, 1).toIso8601String())
        .lt('enrollment_date', DateTime(year + 1, 1, 1).toIso8601String());
    return data.map((row) => _fromRow(row, row['id'] as String)).toList();
  }

  Future<int> getStudentCountByYear(int year) async {
    final response = await _supabase
        .from(_table)
        .select()
        .gte('enrollment_date', DateTime(year, 1, 1).toIso8601String())
        .lt('enrollment_date', DateTime(year + 1, 1, 1).toIso8601String())
        .count(CountOption.exact);
    return response.count;
  }

  Future<String> getStudentIdByEmail(String email) async {
    final data = await _supabase
        .from(_table)
        .select()
        .eq('email', email)
        .maybeSingle();
    if (data != null) {
      return data['id'] as String;
    }
    return '';
  }

  Map<String, dynamic> _toRow(EnrolledStudent student) => {
    'name': student.name,
    'email': student.email,
    'father_name': student.fatherName,
    'level': student.level,
    'contact_number': student.contactNumber,
    'father_contact_number': student.fatherContactNumber,
    'address': student.address,
    'date_of_birth': student.dateOfBirth.toIso8601String(),
    'gender': student.gender,
    'enrollment_date': student.enrollmentDate.toIso8601String(),
    'shift_id': student.shiftId,
  };

  EnrolledStudent _fromRow(Map<String, dynamic> row, String id) =>
      EnrolledStudent.fromMap({
        'name': row['name'],
        'email': row['email'],
        'father_name': row['father_name'],
        'level': row['level'],
        'contact_number': row['contact_number'],
        'father_contact_number': row['father_contact_number'],
        'address': row['address'],
        'date_of_birth': row['date_of_birth'],
        'gender': row['gender'],
        'enrollmentDate': row['enrollment_date'],
        'shift_id': row['shift_id'],
      }, id);
}
