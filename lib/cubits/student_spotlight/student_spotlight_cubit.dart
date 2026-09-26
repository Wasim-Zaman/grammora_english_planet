import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/student_spotlight/student_spotlight_service.dart';

import 'student_spotlight_state.dart';

class StudentSpotlightCubit extends Cubit<StudentSpotlightState> {
  final StudentSpotlightService _service;
  static const int _pageSize = 10;
  Timer? _debounceTimer;

  StudentSpotlightCubit(this._service) : super(const StudentSpotlightState());

  Future<void> fetchPage(int page, {bool silent = false}) async {
    if (state.isLoading) return;
    emit(state.copyWith(
      isLoading: !silent,
      isRefreshing: silent,
      error: null,
    ));

    try {
      final result = await _service.getSpotlightsPaginated(
        page: page,
        pageSize: _pageSize,
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
        awardFilter: state.awardFilter,
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

  void setAwardFilter(String filter) {
    emit(state.copyWith(awardFilter: filter, currentPage: 0));
    fetchPage(0);
  }

  Future<void> toggleFeatured(String id, bool isFeatured) async {
    try {
      await _service.toggleFeatured(id, isFeatured);
      // Optimistically update state
      final updated = state.items.map((item) {
        if (item.id == id) {
          return item.copyWith(isFeatured: isFeatured);
        }
        return item;
      }).toList();
      emit(state.copyWith(items: updated));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      await refresh();
    }
  }

  Future<void> deleteSpotlight(String id) async {
    try {
      await _service.deleteSpotlight(id);
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
