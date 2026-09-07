import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'admission_form_state.dart';

class AdmissionFormCubit extends Cubit<AdmissionFormState> {
  AdmissionFormCubit({DateTime? startDate, DateTime? endDate})
      : super(AdmissionFormState(
          startDate: startDate ?? DateTime.now(),
          endDate: endDate ?? DateTime.now().add(const Duration(days: 30)),
        ));

  void setStartDate(DateTime d) => emit(state.copyWith(startDate: d));

  void setEndDate(DateTime d) => emit(state.copyWith(endDate: d));
}
