import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/models/course_outline.dart';
import 'package:gep/services/courses_outline/courses_outline_service.dart';

import 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  final CoursesOutlineService _service;
  static const int _pageSize = 10;
  Timer? _debounceTimer;

  CoursesCubit(this._service) : super(const CoursesState());

  Future<void> fetchPage(int page, {bool silent = false}) async {
    if (state.isLoading) return;
    emit(state.copyWith(
      isLoading: !silent,
      isRefreshing: silent,
      error: null,
    ));
    try {
      final result = await _service.getCoursesPaginated(
        page: page,
        pageSize: _pageSize,
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
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

  Future<void> addCourse(Course course) async {
    try {
      await _service.addCourse(course);
      await refresh();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateCourse(String id, Course course) async {
    try {
      await _service.updateCourse(id, course);
      await refresh();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteCourse(String id) async {
    try {
      await _service.deleteCourse(id);
      await refresh();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
