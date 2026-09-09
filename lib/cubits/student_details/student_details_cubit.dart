import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/services/shifts/shifts_service.dart';

import 'student_details_state.dart';

class StudentDetailsCubit extends Cubit<StudentDetailsState> {
  final ShiftsService _shiftsService;

  StudentDetailsCubit({ShiftsService? shiftsService})
      : _shiftsService = shiftsService ?? ShiftsService(),
        super(const StudentDetailsState());

  Future<void> loadShift(String? shiftId) async {
    if (shiftId == null || shiftId.isEmpty) return;

    emit(state.copyWith(isLoading: true));
    try {
      final shift = await _shiftsService.getShift(shiftId);
      emit(state.copyWith(shift: shift, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
