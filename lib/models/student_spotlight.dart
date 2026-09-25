class StudentSpotlightModel {
  final String id;
  final String studentName;
  final String awardTitle;
  final String period;
  final String courseOrBatch;
  final String imageUrl;
  final String quoteOrMessage;
  final String achievementHighlights;
  final bool isFeatured;
  final DateTime? createdAt;

  const StudentSpotlightModel({
    required this.id,
    required this.studentName,
    required this.awardTitle,
    required this.period,
    required this.courseOrBatch,
    required this.imageUrl,
    this.quoteOrMessage = '',
    this.achievementHighlights = '',
    this.isFeatured = true,
    this.createdAt,
  });

  StudentSpotlightModel copyWith({
    String? id,
    String? studentName,
    String? awardTitle,
    String? period,
    String? courseOrBatch,
    String? imageUrl,
    String? quoteOrMessage,
    String? achievementHighlights,
    bool? isFeatured,
    DateTime? createdAt,
  }) {
    return StudentSpotlightModel(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      awardTitle: awardTitle ?? this.awardTitle,
      period: period ?? this.period,
      courseOrBatch: courseOrBatch ?? this.courseOrBatch,
      imageUrl: imageUrl ?? this.imageUrl,
      quoteOrMessage: quoteOrMessage ?? this.quoteOrMessage,
      achievementHighlights:
          achievementHighlights ?? this.achievementHighlights,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory StudentSpotlightModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return StudentSpotlightModel(
      id: id,
      studentName: map['student_name'] ?? map['studentName'] ?? '',
      awardTitle: map['award_title'] ?? map['awardTitle'] ?? 'Student of the Month',
      period: map['period'] ?? '',
      courseOrBatch: map['course_or_batch'] ?? map['courseOrBatch'] ?? '',
      imageUrl: map['image_url'] ?? map['imageUrl'] ?? '',
      quoteOrMessage: map['quote_or_message'] ?? map['quoteOrMessage'] ?? '',
      achievementHighlights:
          map['achievement_highlights'] ?? map['achievementHighlights'] ?? '',
      isFeatured: map['is_featured'] ?? map['isFeatured'] ?? true,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_name': studentName,
      'award_title': awardTitle,
      'period': period,
      'course_or_batch': courseOrBatch,
      'image_url': imageUrl,
      'quote_or_message': quoteOrMessage,
      'achievement_highlights': achievementHighlights,
      'is_featured': isFeatured,
    };
  }
}
