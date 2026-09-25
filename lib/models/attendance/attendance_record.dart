class AttendanceRecord {
  final String id;
  final String shiftId;
  final String studentId;
  final DateTime date;
  final DateTime? markedAt;
  final String markedBy;

  AttendanceRecord({
    required this.id,
    required this.shiftId,
    required this.studentId,
    required this.date,
    this.markedAt,
    required this.markedBy,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] ?? '',
      shiftId: map['shift_id'] ?? '',
      studentId: map['student_id'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      markedAt: DateTime.tryParse(map['marked_at'] ?? ''),
      markedBy: map['marked_by'] ?? 'qr_scan',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shift_id': shiftId,
      'student_id': studentId,
      'date': date.toIso8601String().split('T').first,
      'marked_by': markedBy,
    };
  }
}
