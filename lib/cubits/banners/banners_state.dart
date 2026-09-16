import 'package:equatable/equatable.dart';
import 'package:gep/models/banner.dart';

class BannersState extends Equatable {
  final List<BannerModel> items;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String searchQuery;

  const BannersState({
    this.items = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.currentPage = 0,
    this.hasMore = true,
    this.searchQuery = '',
  });

  BannersState copyWith({
    List<BannerModel>? items,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
  }) {
    return BannersState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props =>
      [items, isLoading, isRefreshing, error, currentPage, hasMore, searchQuery];
}
