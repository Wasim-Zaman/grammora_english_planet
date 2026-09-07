part of 'update_form_cubit.dart';

class UpdateFormState extends Equatable {
  final DateTime date;
  final UpdateType type;

  const UpdateFormState({required this.date, required this.type});

  UpdateFormState copyWith({DateTime? date, UpdateType? type}) {
    return UpdateFormState(
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [date, type];
}
