import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';

class WeekFormData {
  final TextEditingController titleController;
  final List<TextEditingController> topicControllers;

  WeekFormData({
    required this.titleController,
    required this.topicControllers,
  });

  void dispose() {
    titleController.dispose();
    for (final c in topicControllers) {
      c.dispose();
    }
  }
}

class CourseFormState extends Equatable {
  final List<WeekFormData> weeks;
  final int version;

  const CourseFormState({
    required this.weeks,
    this.version = 0,
  });

  @override
  List<Object?> get props => [weeks, version];
}
