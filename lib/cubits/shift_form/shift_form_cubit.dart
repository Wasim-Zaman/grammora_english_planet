import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'shift_form_state.dart';

class ShiftFormCubit extends Cubit<ShiftFormState> {
  ShiftFormCubit(List<String> initialDays)
      : super(ShiftFormState(selectedDays: List.of(initialDays)));

  void toggleDay(String day) {
    final days = List<String>.of(state.selectedDays);
    if (days.contains(day)) {
      days.remove(day);
    } else {
      days.add(day);
    }
    emit(state.copyWith(selectedDays: days));
  }
}
