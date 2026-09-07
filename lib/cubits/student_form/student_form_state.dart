part of 'student_form_cubit.dart';

class StudentFormState extends Equatable {
  final DateTime dateOfBirth;
  final String gender;
  final DateTime enrollmentDate;
  final String? selectedShiftId;
  final List<Shift> shifts;
  final bool isSaving;
  final String? error;

  const StudentFormState({
    required this.dateOfBirth,
    this.gender = 'Male',
    required this.enrollmentDate,
    this.selectedShiftId,
    this.shifts = const [],
    this.isSaving = false,
    this.error,
  });

  StudentFormState copyWith({
    DateTime? dateOfBirth,
    String? gender,
    DateTime? enrollmentDate,
    String? selectedShiftId,
    bool clearShift = false,
    List<Shift>? shifts,
    bool? isSaving,
    String? error,
  }) {
    return StudentFormState(
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      selectedShiftId: clearShift
          ? null
          : (selectedShiftId ?? this.selectedShiftId),
      shifts: shifts ?? this.shifts,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    dateOfBirth,
    gender,
    enrollmentDate,
    selectedShiftId,
    shifts,
    isSaving,
    error,
  ];
}
