part of 'qr_attendance_cubit.dart';

class QrAttendanceState extends Equatable {
  final List<Shift> shifts;
  final Shift? selectedShift;
  final DateTime selectedDate;
  final bool isGenerating;
  final String? qrToken;
  final String? error;

  const QrAttendanceState({
    this.shifts = const [],
    this.selectedShift,
    required this.selectedDate,
    this.isGenerating = false,
    this.qrToken,
    this.error,
  });

  QrAttendanceState copyWith({
    List<Shift>? shifts,
    Shift? selectedShift,
    DateTime? selectedDate,
    bool? isGenerating,
    String? qrToken,
    bool clearQrToken = false,
    String? error,
    bool clearError = false,
  }) {
    return QrAttendanceState(
      shifts: shifts ?? this.shifts,
      selectedShift: selectedShift ?? this.selectedShift,
      selectedDate: selectedDate ?? this.selectedDate,
      isGenerating: isGenerating ?? this.isGenerating,
      qrToken: clearQrToken ? null : (qrToken ?? this.qrToken),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props =>
      [shifts, selectedShift, selectedDate, isGenerating, qrToken, error];
}
