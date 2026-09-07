import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/services/attendance/attendance_service.dart';

part 'student_attendance_state.dart';

class StudentAttendanceCubit extends Cubit<StudentAttendanceState> {
  final AttendanceService _service;

  StudentAttendanceCubit(this._service) : super(StudentAttendanceState());

  Future<void> loadMonthly(String studentId, int year, int month) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final summary = await _service.getStudentAttendanceSummary(
        studentId, year, month,
      );
      final daily = await _service.getStudentMonthlyAttendance(
        studentId, year, month,
      );
      emit(state.copyWith(
        isLoading: false,
        summary: summary,
        dailyRecords: daily,
        year: year,
        month: month,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadWeekly(String studentId, DateTime weekStart) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final end = weekStart.add(const Duration(days: 6));
      final daily = await _service.getStudentAttendanceRange(
        studentId, weekStart, end,
      );
      final present = daily.where((r) => r['is_present'] == true).length;
      emit(state.copyWith(
        isLoading: false,
        dailyRecords: daily,
        summary: {'total_days': daily.length, 'present_days': present, 'percentage': daily.isEmpty ? 0 : ((present / daily.length) * 100).round()},        year: weekStart.year,
        month: weekStart.month,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void previousMonth() {
    final newMonth = state.month - 1;
    final newYear = newMonth < 1 ? state.year - 1 : state.year;
    emit(state.copyWith(year: newYear, month: newMonth < 1 ? 12 : newMonth));
  }

  void nextMonth() {
    final newMonth = state.month + 1;
    final newYear = newMonth > 12 ? state.year + 1 : state.year;
    emit(state.copyWith(year: newYear, month: newMonth > 12 ? 1 : newMonth));
  }
}
