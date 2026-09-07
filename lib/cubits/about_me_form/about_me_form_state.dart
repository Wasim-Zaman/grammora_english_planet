part of 'about_me_form_cubit.dart';

class AboutMeFormState extends Equatable {
  final File? profileImage;
  final File? resume;

  const AboutMeFormState({this.profileImage, this.resume});

  AboutMeFormState copyWith({
    File? profileImage,
    File? resume,
    bool clearProfileImage = false,
    bool clearResume = false,
  }) {
    return AboutMeFormState(
      profileImage: clearProfileImage ? null : (profileImage ?? this.profileImage),
      resume: clearResume ? null : (resume ?? this.resume),
    );
  }

  @override
  List<Object?> get props => [profileImage, resume];
}
