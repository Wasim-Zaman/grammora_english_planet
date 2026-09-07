import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/course_outline.dart';

part 'course_form_state.dart';

class CourseFormCubit extends Cubit<CourseFormState> {
  CourseFormCubit(List<Week> initialWeeks)
      : super(CourseFormState(weeks: List.of(initialWeeks)));

  void addWeek() {
    emit(state.copyWith(weeks: [...state.weeks, Week(title: '', topics: [''])]));
  }

  void removeWeek(int index) {
    final weeks = List<Week>.of(state.weeks)..removeAt(index);
    emit(state.copyWith(weeks: weeks));
  }

  void setWeekTitle(int index, String title) {
    final weeks = List<Week>.of(state.weeks);
    weeks[index] = Week(title: title, topics: weeks[index].topics);
    emit(state.copyWith(weeks: weeks));
  }

  void addTopic(int weekIndex) {
    final weeks = List<Week>.of(state.weeks);
    final week = weeks[weekIndex];
    weeks[weekIndex] = Week(title: week.title, topics: [...week.topics, '']);
    emit(state.copyWith(weeks: weeks));
  }

  void removeTopic(int weekIndex, int topicIndex) {
    final weeks = List<Week>.of(state.weeks);
    final week = weeks[weekIndex];
    weeks[weekIndex] = Week(
      title: week.title,
      topics: List<String>.of(week.topics)..removeAt(topicIndex),
    );
    emit(state.copyWith(weeks: weeks));
  }

  void setTopic(int weekIndex, int topicIndex, String value) {
    final weeks = List<Week>.of(state.weeks);
    final week = weeks[weekIndex];
    final topics = List<String>.of(week.topics);
    topics[topicIndex] = value;
    weeks[weekIndex] = Week(title: week.title, topics: topics);
    emit(state.copyWith(weeks: weeks));
  }
}
