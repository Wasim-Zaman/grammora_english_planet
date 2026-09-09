class Shift {
  final String id;
  final String name;
  final String startTime;
  final String endTime;
  final List<String> days;
  final DateTime createdAt;

  Shift({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.days,
    required this.createdAt,
  });

  Shift copyWith({
    String? name,
    String? startTime,
    String? endTime,
    List<String>? days,
  }) {
    return Shift(
      id: id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      days: days ?? this.days,
      createdAt: createdAt,
    );
  }

  factory Shift.fromMap(Map<String, dynamic> map, String id) {
    return Shift(
      id: id,
      name: map['name'] ?? '',
      startTime: map['start_time'] ?? '',
      endTime: map['end_time'] ?? '',
      days: (map['days'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'start_time': startTime,
      'end_time': endTime,
      'days': days,
    };
  }

  String get timeRange => '$startTime – $endTime';
  String get daysLabel => days.join(', ');
}
