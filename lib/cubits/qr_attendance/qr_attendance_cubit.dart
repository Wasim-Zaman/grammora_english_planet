import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/models/shift/shift.dart';
import 'package:gep/services/attendance/attendance_service.dart';
import 'package:gep/services/shifts/shifts_service.dart';

part 'qr_attendance_state.dart';

class QrAttendanceCubit extends Cubit<QrAttendanceState> {
  final ShiftsService _shiftsService;
  final AttendanceService _attendanceService;

  QrAttendanceCubit(this._shiftsService, this._attendanceService)
      : super(QrAttendanceState(selectedDate: DateTime.now()));

  Future<void> loadShifts() async {
    try {
      final shifts = await _shiftsService.getAllShifts();
      emit(state.copyWith(
        shifts: shifts,
        selectedShift:
            state.selectedShift ?? (shifts.isNotEmpty ? shifts.first : null),
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void setShift(Shift shift) => emit(state.copyWith(selectedShift: shift));

  void setDate(DateTime date) => emit(state.copyWith(selectedDate: date));

  Future<void> generateQr() async {
    if (state.selectedShift == null) return;
    emit(state.copyWith(isGenerating: true, clearError: true));
    try {
      final qr = await _attendanceService.generateQrCode(
        state.selectedShift!.id,
        state.selectedDate,
      );
      emit(state.copyWith(isGenerating: false, qrToken: qr.token));
    } catch (e) {
      emit(state.copyWith(isGenerating: false, error: e.toString()));
    }
  }
}
