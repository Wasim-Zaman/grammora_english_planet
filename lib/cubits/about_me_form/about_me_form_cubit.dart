import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'about_me_form_state.dart';

class AboutMeFormCubit extends Cubit<AboutMeFormState> {
  AboutMeFormCubit() : super(const AboutMeFormState());

  void setProfileImage(File? file) {
    emit(state.copyWith(profileImageFile: () => file));
  }

  void setResume(File? file) {
    emit(state.copyWith(resumeFile: () => file));
  }

  void clearResume() {
    emit(state.copyWith(resumeFile: () => null));
  }

  void clearProfileImage() {
    emit(state.copyWith(profileImageFile: () => null));
  }
}
