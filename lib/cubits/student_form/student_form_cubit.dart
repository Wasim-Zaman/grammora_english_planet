import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/models/enrolled_students.dart';
import 'package:gep/services/enrolled_students/enrolled_students_services.dart';
import 'package:gep/services/shifts/shifts_service.dart';

import 'student_form_state.dart';

class StudentFormCubit extends Cubit<StudentFormState> {
  final ShiftsService _shiftsService;

  StudentFormCubit({
    ShiftsService? shiftsService,
    DateTime? initialDob,
    String initialGender = 'Male',
    String? initialShiftId,
    DateTime? initialEnrollmentDate,
  })  : _shiftsService = shiftsService ?? ShiftsService(),
        super(StudentFormState(
          dateOfBirth: initialDob,
          gender: initialGender,
          selectedShiftId: initialShiftId,
          enrollmentDate: initialEnrollmentDate,
        ));

  Future<void> loadShifts() async {
    try {
      final shifts = await _shiftsService.getAllShifts();
      emit(state.copyWith(shifts: shifts));
    } catch (_) {
      // Shifts are optional; don't block
    }
  }

  void setDateOfBirth(DateTime dob) {
    emit(state.copyWith(dateOfBirth: dob));
  }

  void setGender(String gender) {
    emit(state.copyWith(gender: gender));
  }

  void setSelectedShiftId(String? shiftId) {
    emit(state.copyWith(selectedShiftId: () => shiftId));
  }

  void setEnrollmentDate(DateTime date) {
    emit(state.copyWith(enrollmentDate: date));
  }

  Future<bool> saveStudent({
    required EnrolledStudentsServices service,
    required EnrolledStudent student,
    bool isEdit = false,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      if (isEdit) {
        await service.updateStudent(student.id, student);
      } else {
        await service.addStudent(student);
      }
      emit(state.copyWith(isLoading: false, isSuccess: true));
      return true;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }

  Future<bool> deleteStudent({
    required EnrolledStudentsServices service,
    required String studentId,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await service.deleteStudent(studentId);
      emit(state.copyWith(isLoading: false, isSuccess: true));
      return true;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }
}
