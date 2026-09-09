import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/models/updates.dart';
import 'update_form_state.dart';

class UpdateFormCubit extends Cubit<UpdateFormState> {
  UpdateFormCubit({DateTime? initialDate, UpdateType? initialType})
      : super(UpdateFormState(
          selectedDate: initialDate,
          selectedType: initialType ?? UpdateType.newCourse,
        ));

  void setDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  void setType(UpdateType type) {
    emit(state.copyWith(selectedType: type));
  }
}
