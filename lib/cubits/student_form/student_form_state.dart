import 'package:equatable/equatable.dart';
import 'package:gep/models/shift/shift.dart';

class StudentFormState extends Equatable {
  final DateTime dateOfBirth;
  final String gender;
  final String? selectedShiftId;
  final DateTime enrollmentDate;
  final List<Shift> shifts;
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  StudentFormState({
    DateTime? dateOfBirth,
    this.gender = 'Male',
    this.selectedShiftId,
    DateTime? enrollmentDate,
    this.shifts = const [],
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  })  : dateOfBirth = dateOfBirth ?? DateTime.now(),
        enrollmentDate = enrollmentDate ?? DateTime.now();

  StudentFormState copyWith({
    DateTime? dateOfBirth,
    String? gender,
    String? Function()? selectedShiftId,
    DateTime? enrollmentDate,
    List<Shift>? shifts,
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return StudentFormState(
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      selectedShiftId:
          selectedShiftId != null ? selectedShiftId() : this.selectedShiftId,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      shifts: shifts ?? this.shifts,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        dateOfBirth,
        gender,
        selectedShiftId,
        enrollmentDate,
        shifts,
        isLoading,
        isSuccess,
        error,
      ];
}
