import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/student_spotlight/student_spotlight_service.dart';

import 'user_student_spotlight_state.dart';

class UserStudentSpotlightCubit extends Cubit<UserStudentSpotlightState> {
  final StudentSpotlightService _service;
  StreamSubscription? _subscription;

  UserStudentSpotlightCubit(this._service)
      : super(const UserStudentSpotlightState()) {
    initSubscription();
  }

  void initSubscription() {
    emit(state.copyWith(isLoading: true, error: null));
    _subscription?.cancel();
    _subscription = _service.getSpotlightsStream().listen(
      (spotlights) {
        emit(state.copyWith(
          spotlights: spotlights,
          isLoading: false,
          error: null,
        ));
      },
      onError: (e) {
        emit(state.copyWith(
          isLoading: false,
          error: e.toString(),
        ));
      },
    );
  }

  void setFilter(String filter) {
    emit(state.copyWith(selectedFilter: filter));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
