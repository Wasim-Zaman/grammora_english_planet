import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/models/enrolled_students.dart';
import 'package:gep/models/shift/shift.dart';
import 'package:gep/services/shifts/shifts_service.dart';

part 'student_form_state.dart';

class StudentFormCubit extends Cubit<StudentFormState> {
  final ShiftsService _shiftsService;

  StudentFormCubit(this._shiftsService, {EnrolledStudent? student})
    : super(
        StudentFormState(
          dateOfBirth: student?.dateOfBirth ?? DateTime.now(),
          gender: student?.gender ?? 'Male',
          enrollmentDate: student?.enrollmentDate ?? DateTime.now(),
          selectedShiftId: student?.shiftId,
        ),
      );

  Future<void> loadShifts() async {
    try {
      final shifts = await _shiftsService.getAllShifts();
      emit(state.copyWith(shifts: shifts));
    } catch (_) {}
  }

  void setDateOfBirth(DateTime d) => emit(state.copyWith(dateOfBirth: d));

  void setGender(String g) => emit(state.copyWith(gender: g));

  void setEnrollmentDate(DateTime d) =>
      emit(state.copyWith(enrollmentDate: d));

  void setShift(String? shiftId) => emit(
    state.copyWith(selectedShiftId: shiftId, clearShift: shiftId == null),
  );

  void setSaving(bool v) => emit(state.copyWith(isSaving: v));

  void setError(String? e) => emit(state.copyWith(error: e));
}
