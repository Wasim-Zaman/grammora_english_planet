import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/models/shift/shift.dart';
import 'package:gep/services/shifts/shifts_service.dart';

part 'student_details_state.dart';

class StudentDetailsCubit extends Cubit<StudentDetailsState> {
  final ShiftsService _shiftsService;

  StudentDetailsCubit(this._shiftsService)
      : super(const StudentDetailsState());

  Future<void> loadShift(String? shiftId) async {
    if (shiftId == null || shiftId.isEmpty) {
      emit(state.copyWith(isLoading: false));
      return;
    }
    emit(state.copyWith(isLoading: true));
    try {
      final shift = await _shiftsService.getShift(shiftId);
      emit(state.copyWith(isLoading: false, shift: shift));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
