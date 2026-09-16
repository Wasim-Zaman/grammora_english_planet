class QrCodeData {
  final String shiftId;
  final DateTime date;
  final String token;

  QrCodeData({
    required this.shiftId,
    required this.date,
    required this.token,
  });

  factory QrCodeData.fromMap(Map<String, dynamic> map) {
    return QrCodeData(
      shiftId: map['shift_id'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      token: map['qr_token'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shift_id': shiftId,
      'date': date.toIso8601String().split('T').first,
      'qr_token': token,
    };
  }
}
