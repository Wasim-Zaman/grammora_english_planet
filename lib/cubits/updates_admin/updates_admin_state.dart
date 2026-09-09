import 'package:equatable/equatable.dart';
import 'package:gep/models/updates.dart';

class UpdatesAdminState extends Equatable {
  final List<Updates> items;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String searchQuery;

  const UpdatesAdminState({
    this.items = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.currentPage = 0,
    this.hasMore = true,
    this.searchQuery = '',
  });

  UpdatesAdminState copyWith({
    List<Updates>? items,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
  }) {
    return UpdatesAdminState(
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
