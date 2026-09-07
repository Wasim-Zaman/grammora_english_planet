part of 'course_form_cubit.dart';

class CourseFormState extends Equatable {
  final List<Week> weeks;

  const CourseFormState({this.weeks = const []});

  CourseFormState copyWith({List<Week>? weeks}) {
    return CourseFormState(weeks: weeks ?? this.weeks);
  }

  @override
  List<Object?> get props => [weeks];
}
