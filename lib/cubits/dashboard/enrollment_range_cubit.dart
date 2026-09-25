import 'package:flutter_bloc/flutter_bloc.dart';

enum EnrollmentTimeRange { rolling6Months, thisYear }

class EnrollmentTimeRangeCubit extends Cubit<EnrollmentTimeRange> {
  EnrollmentTimeRangeCubit() : super(EnrollmentTimeRange.rolling6Months);

  void setRange(EnrollmentTimeRange range) => emit(range);
  void selectRolling6Months() => emit(EnrollmentTimeRange.rolling6Months);
  void selectThisYear() => emit(EnrollmentTimeRange.thisYear);
}
