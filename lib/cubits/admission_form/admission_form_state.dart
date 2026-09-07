part of 'admission_form_cubit.dart';

class AdmissionFormState extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const AdmissionFormState({required this.startDate, required this.endDate});

  AdmissionFormState copyWith({DateTime? startDate, DateTime? endDate}) {
    return AdmissionFormState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [startDate, endDate];
}
