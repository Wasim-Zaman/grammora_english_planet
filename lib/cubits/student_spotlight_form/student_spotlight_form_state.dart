import 'package:equatable/equatable.dart';

abstract class StudentSpotlightFormState extends Equatable {
  const StudentSpotlightFormState();

  @override
  List<Object?> get props => [];
}

class StudentSpotlightFormInitial extends StudentSpotlightFormState {
  const StudentSpotlightFormInitial();
}

class StudentSpotlightFormLoading extends StudentSpotlightFormState {
  const StudentSpotlightFormLoading();
}

class StudentSpotlightFormSuccess extends StudentSpotlightFormState {
  final String message;
  const StudentSpotlightFormSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class StudentSpotlightFormFailure extends StudentSpotlightFormState {
  final String error;
  const StudentSpotlightFormFailure(this.error);

  @override
  List<Object?> get props => [error];
}
