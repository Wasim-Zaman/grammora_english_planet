import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/services/notes/notes_service.dart';

import 'notes_categories_state.dart';

class NotesCategoriesCubit extends Cubit<NotesCategoriesState> {
  final NotesService _notesService;
  static const int _pageSize = 15;
  Timer? _debounceTimer;

  NotesCategoriesCubit(this._notesService) : super(const NotesCategoriesState());

  /// Load a specific page. Set [silent] to true to keep existing UI
  /// visible while data refreshes in the background.
  Future<void> fetchPage(int page, {bool silent = false}) async {
    if (state.isLoading) return;

    emit(state.copyWith(
      isLoading: !silent,
      isRefreshing: silent,
      error: null,
    ));

    try {
      final result = await _notesService.getCategoriesPaginated(
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

  /// Refresh the current page without showing a full-screen loader.
  Future<void> refresh() => fetchPage(state.currentPage, silent: true);

  /// Load the next page if more data exists.
  Future<void> nextPage() {
    if (!state.hasMore || state.isLoading) return Future.value();
    return fetchPage(state.currentPage + 1);
  }

  /// Load the previous page if not on the first page.
  Future<void> previousPage() {
    if (state.currentPage <= 0 || state.isLoading) return Future.value();
    return fetchPage(state.currentPage - 1);
  }

  /// Jump to a specific page.
  Future<void> goToPage(int page) {
    if (page < 0 || state.isLoading) return Future.value();
    return fetchPage(page);
  }

  /// Update search query and reload page 0 after a short debounce.
  void setSearchQuery(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      emit(state.copyWith(searchQuery: query.trim(), currentPage: 0));
      fetchPage(0);
    });
  }

  /// Clear search and reload.
  Future<void> clearSearch() async {
    _debounceTimer?.cancel();
    emit(state.copyWith(searchQuery: '', currentPage: 0));
    return fetchPage(0);
  }

  /// Add a category and refresh the current page.
  Future<void> addCategory(String category) async {
    try {
      await _notesService.addCategory(category);
      await refresh();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Delete a category and refresh the current page.
  Future<void> deleteCategory(String category) async {
    try {
      await _notesService.deleteCategory(category);
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
