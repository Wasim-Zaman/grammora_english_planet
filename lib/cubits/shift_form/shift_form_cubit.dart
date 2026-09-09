import 'package:flutter_bloc/flutter_bloc.dart';
import 'shift_form_state.dart';

class ShiftFormCubit extends Cubit<ShiftFormState> {
  ShiftFormCubit(List<String> initialDays)
      : super(ShiftFormState(selectedDays: initialDays));

  void toggleDay(String day) {
    final updated = List<String>.from(state.selectedDays);
    if (updated.contains(day)) {
      updated.remove(day);
    } else {
      updated.add(day);
    }
    emit(state.copyWith(selectedDays: updated));
  }

  void setDays(List<String> days) {
    emit(state.copyWith(selectedDays: List<String>.from(days)));
  }
}
