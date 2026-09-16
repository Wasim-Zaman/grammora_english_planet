import 'package:flutter_bloc/flutter_bloc.dart';
import 'admission_form_state.dart';

class AdmissionFormCubit extends Cubit<AdmissionFormState> {
  AdmissionFormCubit({DateTime? initialStartDate, DateTime? initialEndDate})
      : super(AdmissionFormState(
          startDate: initialStartDate,
          endDate: initialEndDate,
        ));

  void setStartDate(DateTime date) {
    emit(state.copyWith(startDate: date));
  }

  void setEndDate(DateTime date) {
    emit(state.copyWith(endDate: date));
  }
}
