import 'dart:io';
import 'package:equatable/equatable.dart';

class AboutMeFormState extends Equatable {
  final File? profileImageFile;
  final File? resumeFile;

  const AboutMeFormState({
    this.profileImageFile,
    this.resumeFile,
  });

  AboutMeFormState copyWith({
    File? Function()? profileImageFile,
    File? Function()? resumeFile,
  }) {
    return AboutMeFormState(
      profileImageFile: profileImageFile != null
          ? profileImageFile()
          : this.profileImageFile,
      resumeFile: resumeFile != null ? resumeFile() : this.resumeFile,
    );
  }

  @override
  List<Object?> get props => [profileImageFile, resumeFile];
}
