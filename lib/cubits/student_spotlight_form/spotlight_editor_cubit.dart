import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/enrolled_students.dart';

class SpotlightEditorState extends Equatable {
  final String awardTitle;
  final bool isFeatured;
  final EnrolledStudent? selectedStudent;

  const SpotlightEditorState({
    this.awardTitle = 'Student of the Month',
    this.isFeatured = true,
    this.selectedStudent,
  });

  SpotlightEditorState copyWith({
    String? awardTitle,
    bool? isFeatured,
    EnrolledStudent? Function()? selectedStudent,
  }) {
    return SpotlightEditorState(
      awardTitle: awardTitle ?? this.awardTitle,
      isFeatured: isFeatured ?? this.isFeatured,
      selectedStudent:
          selectedStudent != null ? selectedStudent() : this.selectedStudent,
    );
  }

  @override
  List<Object?> get props => [awardTitle, isFeatured, selectedStudent];
}

class SpotlightEditorCubit extends Cubit<SpotlightEditorState> {
  SpotlightEditorCubit({
    String initialAward = 'Student of the Month',
    bool initialFeatured = true,
  }) : super(SpotlightEditorState(
          awardTitle: initialAward,
          isFeatured: initialFeatured,
        ));

  void setAwardTitle(String title) {
    emit(state.copyWith(awardTitle: title));
  }

  void setFeatured(bool featured) {
    emit(state.copyWith(isFeatured: featured));
  }

  void setStudent(EnrolledStudent student) {
    emit(state.copyWith(selectedStudent: () => student));
  }

  void clearStudent() {
    emit(state.copyWith(selectedStudent: () => null));
  }
}

/// Cubit for managing student search query in bottom sheet without setState.
class StudentSearchCubit extends Cubit<String> {
  StudentSearchCubit() : super('');

  void setQuery(String query) {
    emit(query.trim().toLowerCase());
  }

  void clear() {
    emit('');
  }
}
