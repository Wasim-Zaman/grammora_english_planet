import 'package:equatable/equatable.dart';
import 'package:gep/models/student_spotlight.dart';

class StudentSpotlightState extends Equatable {
  final List<StudentSpotlightModel> items;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String searchQuery;
  final String awardFilter;

  const StudentSpotlightState({
    this.items = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.currentPage = 0,
    this.hasMore = false,
    this.searchQuery = '',
    this.awardFilter = 'All',
  });

  StudentSpotlightState copyWith({
    List<StudentSpotlightModel>? items,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
    String? awardFilter,
  }) {
    return StudentSpotlightState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      awardFilter: awardFilter ?? this.awardFilter,
    );
  }

  @override
  List<Object?> get props => [
        items,
        isLoading,
        isRefreshing,
        error,
        currentPage,
        hasMore,
        searchQuery,
        awardFilter,
      ];
}
