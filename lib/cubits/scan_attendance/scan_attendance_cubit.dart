import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/services/attendance/attendance_service.dart';
import 'package:gep/services/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'scan_attendance_state.dart';

class ScanAttendanceCubit extends Cubit<ScanAttendanceState> {
  final AttendanceService _service;
  final SupabaseClient _supabase;
  final AuthService _authService;

  ScanAttendanceCubit({
    AttendanceService? service,
    SupabaseClient? supabase,
    AuthService? authService,
  })  : _service = service ?? AttendanceService(),
        _supabase = supabase ?? Supabase.instance.client,
        _authService = authService ?? AuthService(),
        super(const ScanAttendanceState());

  Future<Map<String, dynamic>?> _getStudentRecord() async {
    final user = _authService.getCurrentUser();
    if (user?.email == null) return null;
    try {
      final data = await _supabase
          .from('enrolled_students')
          .select('id, shift_id')
          .eq('email', user!.email!)
          .maybeSingle();
      return data;
    } catch (_) {
      return null;
    }
  }

  Future<void> onDetect(String rawValue) async {
    if (state.isProcessing || state.isSuccess) return;

    emit(state.copyWith(
      isProcessing: true,
      message: 'Validating…',
      error: null,
    ));

    try {
      final isValid = await _service.validateQrToken(rawValue);
      if (!isValid) {
        emit(state.copyWith(
          isProcessing: false,
          message: 'Invalid or expired QR code',
        ));
        return;
      }

      final qrData = await _service.getQrDataByToken(rawValue);
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

      final alreadyMarked = await _service.isAlreadyMarked(
        qrData.shiftId,
        studentId,
        qrData.date,
      );
      if (alreadyMarked) {
        emit(state.copyWith(
          isProcessing: false,
          isSuccess: true,
          message: 'Attendance already marked for today!',
        ));
        return;
      }

      await _service.markAttendance(
        shiftId: qrData.shiftId,
        studentId: studentId,
        date: qrData.date,
      );

      emit(state.copyWith(
        isProcessing: false,
        isSuccess: true,
        message: 'Attendance marked successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        message: 'Error: $e',
        error: e.toString(),
      ));
    }
  }

  void reset() {
    emit(const ScanAttendanceState());
  }
}
