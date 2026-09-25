import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/banner.dart';
import '../../services/banner/banner_service.dart';
import 'banner_state.dart';

class BannerCubit extends Cubit<BannerState> {
  final Stream<List<BannerModel>> bannersStream;
  final BannerService _bannerService;
  StreamSubscription? _bannerSubscription;

  BannerCubit({required this.bannersStream, BannerService? bannerService})
    : _bannerService = bannerService ?? BannerService(),
      super(BannerInitial()) {
    _initBanners();
  }

  Future<void> fetchBanners() async {
    try {
      final banners = await _bannerService.getBanners();
      emit(BannerLoaded(banners: banners));
    } catch (_) {}
  }

  void _initBanners() {
    emit(BannerLoading());
    fetchBanners();
    _bannerSubscription = bannersStream.listen(
      (banners) {
        emit(BannerLoaded(banners: banners));
      },
      onError: (error) {
        fetchBanners();
      },
    );
  }

  void updateCurrentIndex(int index) {
    if (state is BannerLoaded) {
      final currentState = state as BannerLoaded;
      emit(currentState.copyWith(currentIndex: index));
    }
  }

  @override
  Future<void> close() {
    _bannerSubscription?.cancel();
    return super.close();
  }
}
