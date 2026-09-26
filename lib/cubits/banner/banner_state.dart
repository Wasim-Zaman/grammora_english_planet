// ignore_for_file: depend_on_referenced_packages

import 'package:equatable/equatable.dart';
import '../../models/banner.dart';

abstract class BannerState extends Equatable {
  const BannerState();

  @override
  List<Object?> get props => [];
}

class BannerInitial extends BannerState {}

class BannerLoading extends BannerState {}

class BannerLoaded extends BannerState {
  final List<BannerModel> banners;
  final int currentIndex;

  const BannerLoaded({
    required this.banners,
    this.currentIndex = 0,
  });

  @override
  List<Object?> get props => [banners, currentIndex];

  BannerLoaded copyWith({
    List<BannerModel>? banners,
    int? currentIndex,
  }) {
    return BannerLoaded(
      banners: banners ?? this.banners,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class BannerError extends BannerState {
  final String message;

  const BannerError(this.message);

  @override
  List<Object?> get props => [message];
}
