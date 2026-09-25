import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit managing the active index of the student spotlight carousel on the user dashboard.
class SpotlightCarouselCubit extends Cubit<int> {
  SpotlightCarouselCubit() : super(0);

  void setIndex(int index) {
    if (state != index) {
      emit(index);
    }
  }

  void reset() => emit(0);
}
