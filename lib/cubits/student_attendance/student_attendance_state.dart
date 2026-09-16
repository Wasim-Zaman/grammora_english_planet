part of 'student_attendance_cubit.dart';

class StudentAttendanceState extends Equatable {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> dailyRecords;
  final int year;
  final int month;

  final int viewMode; // 0: monthly, 1: weekly

  StudentAttendanceState({
    this.isLoading = false,
    this.error,
    this.summary = const {},
    this.dailyRecords = const [],
    this.viewMode = 0,
    int? year,
    int? month,
  })  : year = year ?? DateTime.now().year,
        month = month ?? DateTime.now().month;

  StudentAttendanceState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? summary,
    List<Map<String, dynamic>>? dailyRecords,
    int? viewMode,
    int? year,
    int? month,
  }) {
    return StudentAttendanceState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      summary: summary ?? this.summary,
      dailyRecords: dailyRecords ?? this.dailyRecords,
      viewMode: viewMode ?? this.viewMode,
      year: year ?? this.year,
      month: month ?? this.month,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, error, summary, dailyRecords, viewMode, year, month];
}
