import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/updates.dart';

part 'update_form_state.dart';

class UpdateFormCubit extends Cubit<UpdateFormState> {
  UpdateFormCubit({DateTime? date, UpdateType? type})
      : super(UpdateFormState(
          date: date ?? DateTime.now(),
          type: type ?? UpdateType.newCourse,
        ));

  void setDate(DateTime date) => emit(state.copyWith(date: date));

  void setType(UpdateType type) => emit(state.copyWith(type: type));
}
