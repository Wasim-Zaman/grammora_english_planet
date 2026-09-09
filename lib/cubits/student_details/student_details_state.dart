import 'package:equatable/equatable.dart';
import 'package:gep/models/shift/shift.dart';

class StudentDetailsState extends Equatable {
  final Shift? shift;
  final bool isLoading;
  final String? error;

  const StudentDetailsState({
    this.shift,
    this.isLoading = false,
    this.error,
  });

  StudentDetailsState copyWith({
    Shift? shift,
    bool? isLoading,
    String? error,
  }) {
    return StudentDetailsState(
      shift: shift ?? this.shift,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [shift, isLoading, error];
}
