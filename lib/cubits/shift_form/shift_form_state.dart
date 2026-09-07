part of 'shift_form_cubit.dart';

class ShiftFormState extends Equatable {
  final List<String> selectedDays;

  const ShiftFormState({this.selectedDays = const []});

  ShiftFormState copyWith({List<String>? selectedDays}) {
    return ShiftFormState(selectedDays: selectedDays ?? this.selectedDays);
  }

  @override
  List<Object?> get props => [selectedDays];
}
