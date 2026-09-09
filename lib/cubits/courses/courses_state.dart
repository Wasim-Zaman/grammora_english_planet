import 'package:equatable/equatable.dart';
import 'package:gep/models/course_outline.dart';

class CoursesState extends Equatable {
  final List<Course> items;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String searchQuery;

  const CoursesState({
    this.items = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.currentPage = 0,
    this.hasMore = true,
    this.searchQuery = '',
  });

  CoursesState copyWith({
    List<Course>? items,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
  }) {
    return CoursesState(
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
