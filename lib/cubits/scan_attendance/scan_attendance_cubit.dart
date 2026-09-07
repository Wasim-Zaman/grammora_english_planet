import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/services/attendance/attendance_service.dart';
import 'package:gep/services/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'scan_attendance_state.dart';

class ScanAttendanceCubit extends Cubit<ScanAttendanceState> {
  final AttendanceService _attendanceService;
  final AuthService _authService;

  ScanAttendanceCubit(this._attendanceService, this._authService)
      : super(const ScanAttendanceState());

  Future<void> onDetect(String rawValue) async {
    if (state.isProcessing || state.success) return;
    emit(state.copyWith(isProcessing: true, message: 'Validating…'));
    try {
      final isValid = await _attendanceService.validateQrToken(rawValue);
      if (!isValid) {
        emit(state.copyWith(
          isProcessing: false,
          message: 'Invalid or expired QR code',
        ));
        return;
      }

      final qrData = await _attendanceService.getQrDataByToken(rawValue);
      if (qrData == null) {
        emit(state.copyWith(
          isProcessing: false,
          message: 'QR data not found',
        ));
        return;
      }

      final studentRecord = await _getStudentRecord();
      if (studentRecord == null) {
        emit(state.copyWith(
          isProcessing: false,
          message: 'Student record not found. Contact admin.',
        ));
        return;
      }

      final studentId = studentRecord['id']?.toString();
      final studentShiftId = studentRecord['shift_id']?.toString();

      if (studentId == null || studentId.isEmpty) {
        emit(state.copyWith(
          isProcessing: false,
          message: 'Student record not found. Contact admin.',
        ));
        return;
      }
      if (studentShiftId == null || studentShiftId.isEmpty) {
        emit(state.copyWith(
          isProcessing: false,
          message: 'No shift assigned. Contact admin.',
        ));
        return;
      }
      if (studentShiftId != qrData.shiftId) {
        emit(state.copyWith(
          isProcessing: false,
          message: 'This QR is not for your assigned shift.',
        ));
        return;
      }

      final alreadyMarked = await _attendanceService.isAlreadyMarked(
        qrData.shiftId,
        studentId,
        qrData.date,
      );
      if (alreadyMarked) {
        emit(state.copyWith(
          isProcessing: false,
          success: true,
          message: 'Attendance already marked for today!',
        ));
        return;
      }

      await _attendanceService.markAttendance(
        shiftId: qrData.shiftId,
        studentId: studentId,
        date: qrData.date,
      );
      emit(state.copyWith(
        isProcessing: false,
        success: true,
        message: 'Attendance marked successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(isProcessing: false, message: 'Error: $e'));
    }
  }

  Future<Map<String, dynamic>?> _getStudentRecord() async {
    try {
      final user = _authService.getCurrentUser();
      if (user?.email == null) return null;
      final data = await Supabase.instance.client
          .from('enrolled_students')
          .select('id, shift_id')
          .eq('email', user!.email!)
          .maybeSingle();
      return data;
    } catch (_) {
      return null;
    }
  }

  void reset() => emit(const ScanAttendanceState());
}
