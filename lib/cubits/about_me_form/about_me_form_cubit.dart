import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'about_me_form_state.dart';

class AboutMeFormCubit extends Cubit<AboutMeFormState> {
  AboutMeFormCubit() : super(const AboutMeFormState());

  void setProfileImage(File f) => emit(state.copyWith(profileImage: f));

  void setResume(File f) => emit(state.copyWith(resume: f));

  void clearResume() => emit(state.copyWith(clearResume: true));
}
