import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/models/shift/shift.dart';
import 'package:gep/services/attendance/attendance_service.dart';
import 'package:gep/services/shifts/shifts_service.dart';

part 'attendance_admin_state.dart';

class AttendanceAdminCubit extends Cubit<AttendanceAdminState> {
  final AttendanceService _service;
  final ShiftsService _shiftsService = ShiftsService();
  static const int _pageSize = 15;

  AttendanceAdminCubit(this._service) : super(const AttendanceAdminState());

  Future<void> loadShifts() async {
    try {
      final shifts = await _shiftsService.getAllShifts();
      emit(state.copyWith(shifts: shifts));
    } catch (_) {}
  }

  Future<void> fetchPage(int page, {bool silent = false}) async {
    if (state.isLoading) return;
    emit(state.copyWith(
      isLoading: !silent,
      isRefreshing: silent,
      error: null,
    ));
    try {
      final result = await _service.getAttendanceRecordsPaginated(
        page: page,
        pageSize: _pageSize,
        shiftId: state.shiftFilter,
        date: state.dateFilter,
      );
      emit(state.copyWith(
        items: result.items,
        isLoading: false,
        isRefreshing: false,
        currentPage: page,
        hasMore: result.hasMore,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> refresh() => fetchPage(state.currentPage, silent: true);

  Future<void> nextPage() {
    if (!state.hasMore || state.isLoading) return Future.value();
    return fetchPage(state.currentPage + 1);
  }

  Future<void> previousPage() {
    if (state.currentPage <= 0 || state.isLoading) return Future.value();
    return fetchPage(state.currentPage - 1);
  }

  Future<void> goToPage(int page) {
    if (page < 0 || state.isLoading) return Future.value();
    return fetchPage(page);
  }

  void setShiftFilter(String? shiftId) {
    emit(state.copyWith(shiftFilter: shiftId, currentPage: 0));
    fetchPage(0);
  }

  void setDateFilter(DateTime? date) {
    emit(state.copyWith(dateFilter: date, currentPage: 0));
    fetchPage(0);
  }

  void clearFilters() {
    emit(state.copyWith(shiftFilter: null, dateFilter: null, currentPage: 0));
    fetchPage(0);
  }
}
