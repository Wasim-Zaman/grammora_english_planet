import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/models/admission_announcement.dart';
import 'package:gep/services/admissions/admissions_services.dart';

import 'admissions_state.dart';

class AdmissionsCubit extends Cubit<AdmissionsState> {
  final AdmissionsService _service;
  static const int _pageSize = 10;
  Timer? _debounceTimer;

  AdmissionsCubit(this._service) : super(const AdmissionsState());

  Future<void> fetchPage(int page, {bool silent = false}) async {
    if (state.isLoading) return;
    emit(state.copyWith(
      isLoading: !silent,
      isRefreshing: silent,
      error: null,
    ));
    try {
      final result = await _service.getAnnouncementsPaginated(
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

  Future<void> addAnnouncement(AdmissionAnnouncement announcement) async {
    try {
      await _service.addAnnouncement(announcement);
      await refresh();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateAnnouncement(AdmissionAnnouncement announcement) async {
    try {
      await _service.updateAnnouncement(announcement);
      await refresh();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      await _service.deleteAnnouncement(id);
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
