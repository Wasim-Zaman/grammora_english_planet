import 'package:equatable/equatable.dart';
import 'package:gep/models/updates.dart';

class UpdateFormState extends Equatable {
  final DateTime selectedDate;
  final UpdateType selectedType;

  UpdateFormState({
    DateTime? selectedDate,
    this.selectedType = UpdateType.newCourse,
  }) : selectedDate = selectedDate ?? DateTime.now();

  UpdateFormState copyWith({
    DateTime? selectedDate,
    UpdateType? selectedType,
  }) {
    return UpdateFormState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedType: selectedType ?? this.selectedType,
    );
  }

  @override
  List<Object?> get props => [selectedDate, selectedType];
}
