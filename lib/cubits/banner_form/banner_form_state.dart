part of 'banner_form_cubit.dart';

abstract class BannerFormState extends Equatable {
  const BannerFormState();

  @override
  List<Object?> get props => [];
}

class BannerFormInitial extends BannerFormState {
  const BannerFormInitial();
}

class BannerFormLoading extends BannerFormState {
  const BannerFormLoading();
}

class BannerFormSuccess extends BannerFormState {
  final String message;
  const BannerFormSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class BannerFormFailure extends BannerFormState {
  final String error;
  const BannerFormFailure(this.error);

  @override
  List<Object?> get props => [error];
}
