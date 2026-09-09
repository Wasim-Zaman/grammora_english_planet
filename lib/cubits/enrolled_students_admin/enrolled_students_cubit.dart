import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/models/enrolled_students.dart';
import 'package:gep/services/enrolled_students/enrolled_students_services.dart';

import 'enrolled_students_state.dart';

class EnrolledStudentsAdminCubit extends Cubit<EnrolledStudentsState> {
  final EnrolledStudentsServices service;
  static const int _pageSize = 10;
  Timer? _debounceTimer;

  EnrolledStudentsAdminCubit(this.service)
    : super(const EnrolledStudentsState());

  Future<void> fetchPage(int page, {bool silent = false}) async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: !silent, isRefreshing: silent, error: null));
    try {
      final result = await service.getStudentsPaginated(
        page: page,
        pageSize: _pageSize,
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
      );
      emit(
        state.copyWith(
          items: result.items,
          isLoading: false,
          isRefreshing: false,
          currentPage: page,
          hasMore: result.hasMore,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          error: e.toString(),
        ),
      );
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

  void setSearchQuery(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      emit(state.copyWith(searchQuery: query.trim(), currentPage: 0));
      fetchPage(0);
    });
  }

  Future<void> clearSearch() async {
    _debounceTimer?.cancel();
    emit(state.copyWith(searchQuery: '', currentPage: 0));
    return fetchPage(0);
  }

  Future<void> addStudent(EnrolledStudent student) async {
    try {
      await service.addStudent(student);
      await refresh();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateStudent(String id, EnrolledStudent student) async {
    try {
      await service.updateStudent(id, student);
      await refresh();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await service.deleteStudent(id);
      await refresh();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<String> getStudentIdByEmail(String email) async {
    try {
      final studentId = await service.getStudentIdByEmail(email);
      return studentId;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return '';
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
