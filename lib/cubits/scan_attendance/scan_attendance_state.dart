import 'package:equatable/equatable.dart';

class ScanAttendanceState extends Equatable {
  final bool isProcessing;
  final bool isSuccess;
  final String message;
  final String? error;

  const ScanAttendanceState({
    this.isProcessing = false,
    this.isSuccess = false,
    this.message = 'Scan the attendance QR code',
    this.error,
  });

  ScanAttendanceState copyWith({
    bool? isProcessing,
    bool? isSuccess,
    String? message,
    String? error,
  }) {
    return ScanAttendanceState(
      isProcessing: isProcessing ?? this.isProcessing,
      isSuccess: isSuccess ?? this.isSuccess,
      message: message ?? this.message,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isProcessing, isSuccess, message, error];
}
