import 'package:equatable/equatable.dart';

class AdmissionFormState extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  AdmissionFormState({
    DateTime? startDate,
    DateTime? endDate,
  })  : startDate = startDate ?? DateTime.now(),
        endDate = endDate ?? DateTime.now().add(const Duration(days: 30));

  AdmissionFormState copyWith({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return AdmissionFormState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [startDate, endDate];
}
