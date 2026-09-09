import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gep/models/course_outline.dart';
import 'course_form_state.dart';

class CourseFormCubit extends Cubit<CourseFormState> {
  CourseFormCubit(List<Week> initialWeeks)
      : super(const CourseFormState(weeks: [])) {
    _init(initialWeeks);
  }

  void _init(List<Week> initialWeeks) {
    final list = <WeekFormData>[];
    if (initialWeeks.isEmpty) {
      list.add(WeekFormData(
        titleController: TextEditingController(),
        topicControllers: [TextEditingController()],
      ));
    } else {
      for (final w in initialWeeks) {
        list.add(WeekFormData(
          titleController: TextEditingController(text: w.title),
          topicControllers:
              w.topics.map((t) => TextEditingController(text: t)).toList(),
        ));
      }
    }
    emit(CourseFormState(weeks: list, version: 0));
  }

  void addWeek() {
    final updated = List<WeekFormData>.from(state.weeks);
    updated.add(WeekFormData(
      titleController: TextEditingController(),
      topicControllers: [TextEditingController()],
    ));
    emit(CourseFormState(weeks: updated, version: state.version + 1));
  }

  void removeWeek(int index) {
    if (state.weeks.length <= 1) return;
    final updated = List<WeekFormData>.from(state.weeks);
    final removed = updated.removeAt(index);
    removed.dispose();
    emit(CourseFormState(weeks: updated, version: state.version + 1));
  }

  void addTopic(int weekIndex) {
    final updated = List<WeekFormData>.from(state.weeks);
    updated[weekIndex].topicControllers.add(TextEditingController());
    emit(CourseFormState(weeks: updated, version: state.version + 1));
  }

  void removeTopic(int weekIndex, int topicIndex) {
    final updated = List<WeekFormData>.from(state.weeks);
    if (updated[weekIndex].topicControllers.length <= 1) return;
    final removed = updated[weekIndex].topicControllers.removeAt(topicIndex);
    removed.dispose();
    emit(CourseFormState(weeks: updated, version: state.version + 1));
  }

  List<Week> getWeeks() {
    return state.weeks.map((w) {
      return Week(
        title: w.titleController.text,
        topics: w.topicControllers.map((t) => t.text).toList(),
      );
    }).toList();
  }

  @override
  Future<void> close() {
    for (final w in state.weeks) {
      w.dispose();
    }
    return super.close();
  }
}
