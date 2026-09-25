import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/services/notes/notes_service.dart';

import 'user_notes_state.dart';

class UserNotesCubit extends Cubit<UserNotesState> {
  final NotesService _service;
  static const int _pageSize = 15;
  Timer? _debounceTimer;

  UserNotesCubit(this._service) : super(const UserNotesState());

  void setCategory(String category) {
    emit(state.copyWith(category: category, items: [], currentPage: 0, hasMore: true));
    fetchPage(0);
  }

  Future<void> fetchPage(int page, {bool silent = false}) async {
    if (state.isLoading || state.category.isEmpty) return;
    emit(state.copyWith(
      isLoading: !silent,
      isRefreshing: silent,
      error: null,
    ));
    try {
      final result = await _service.getNotesPaginated(
        category: state.category,
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

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
