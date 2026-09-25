import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/models/banner.dart';
import 'package:gep/services/banner/banner_service.dart';

import 'banners_state.dart';

class BannersCubit extends Cubit<BannersState> {
  final BannerService _service;
  static const int _pageSize = 10;
  Timer? _debounceTimer;

  BannersCubit(this._service) : super(const BannersState());

  Future<void> fetchPage(int page, {bool silent = false}) async {
    if (state.isLoading) return;
    emit(state.copyWith(
      isLoading: !silent,
      isRefreshing: silent,
      error: null,
    ));
    try {
      final result = await _service.getBannersPaginated(
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

  Future<void> addBanner(String title, String imageUrl) async {
    try {
      await _service.addBanner(
        BannerModel(id: '', title: title, imageUrl: imageUrl),
      );
      await refresh();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateBanner(String id, BannerModel banner) async {
    try {
      await _service.updateBanner(id, banner);
      await refresh();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteBanner(String id) async {
    try {
      await _service.deleteBanner(id);
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
