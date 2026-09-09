part of 'attendance_admin_cubit.dart';

class AttendanceAdminState extends Equatable {
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String? shiftFilter;
  final DateTime? dateFilter;
  final List<Shift> shifts;

  const AttendanceAdminState({
    this.items = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.currentPage = 0,
    this.hasMore = true,
    this.shiftFilter,
    this.dateFilter,
    this.shifts = const [],
  });

  AttendanceAdminState copyWith({
    List<Map<String, dynamic>>? items,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? shiftFilter,
    DateTime? dateFilter,
    List<Shift>? shifts,
  }) {
    return AttendanceAdminState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      shiftFilter: shiftFilter ?? this.shiftFilter,
      dateFilter: dateFilter ?? this.dateFilter,
      shifts: shifts ?? this.shifts,
    );
  }

  @override
  List<Object?> get props =>
      [items, isLoading, isRefreshing, error, currentPage, hasMore, shiftFilter, dateFilter, shifts];
}
