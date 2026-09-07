part of 'scan_attendance_cubit.dart';

class ScanAttendanceState extends Equatable {
  final bool isProcessing;
  final bool success;
  final String message;

  const ScanAttendanceState({
    this.isProcessing = false,
    this.success = false,
    this.message = 'Scan the attendance QR code',
  });

  ScanAttendanceState copyWith({
    bool? isProcessing,
    bool? success,
    String? message,
  }) {
    return ScanAttendanceState(
      isProcessing: isProcessing ?? this.isProcessing,
      success: success ?? this.success,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [isProcessing, success, message];
}
