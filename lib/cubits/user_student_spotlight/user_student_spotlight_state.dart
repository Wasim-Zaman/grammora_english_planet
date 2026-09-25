import 'package:equatable/equatable.dart';
import 'package:gep/models/student_spotlight.dart';

class UserStudentSpotlightState extends Equatable {
  final List<StudentSpotlightModel> spotlights;
  final bool isLoading;
  final String? error;
  final String selectedFilter;

  const UserStudentSpotlightState({
    this.spotlights = const [],
    this.isLoading = false,
    this.error,
    this.selectedFilter = 'All',
  });

  List<StudentSpotlightModel> get featuredSpotlights =>
      spotlights.where((s) => s.isFeatured).toList();

  List<StudentSpotlightModel> get filteredSpotlights {
    if (selectedFilter == 'All') return spotlights;
    return spotlights
        .where(
          (s) => s.awardTitle.toLowerCase() == selectedFilter.toLowerCase(),
        )
        .toList();
  }

  UserStudentSpotlightState copyWith({
    List<StudentSpotlightModel>? spotlights,
    bool? isLoading,
    String? error,
    String? selectedFilter,
  }) {
    return UserStudentSpotlightState(
      spotlights: spotlights ?? this.spotlights,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object?> get props => [
        spotlights,
        isLoading,
        error,
        selectedFilter,
      ];
}
