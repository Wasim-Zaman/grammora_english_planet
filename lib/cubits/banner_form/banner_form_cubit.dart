import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/banner.dart';
import '../../services/banner/banner_service.dart';
import '../../services/storage/storage_service.dart';


part 'banner_form_state.dart';

class BannerFormCubit extends Cubit<BannerFormState> {
  final BannerService _bannerService;
  final StorageService _storageService;

  BannerFormCubit(this._bannerService, this._storageService)
      : super(const BannerFormInitial());

  void reset() => emit(const BannerFormInitial());

  Future<void> save({
    required String title,
    File? imageFile,
    BannerModel? existingBanner,
  }) async {
    emit(const BannerFormLoading());
    try {
      String imageUrl = existingBanner?.imageUrl ?? '';

      if (imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
        final filePath = 'banners/$fileName';
        imageUrl = await _storageService.uploadFile(filePath, imageFile);

        if (existingBanner != null && existingBanner.imageUrl.isNotEmpty) {
          await _storageService.deleteFile(existingBanner.imageUrl);
        }
      }

      final banner = BannerModel(
        id: existingBanner?.id ?? '',
        title: title,
        imageUrl: imageUrl,
      );

      if (existingBanner == null) {
        await _bannerService.addBanner(banner);
        emit(const BannerFormSuccess('Banner added successfully'));
      } else {
        await _bannerService.updateBanner(existingBanner.id, banner);
        emit(const BannerFormSuccess('Banner updated successfully'));
      }
    } catch (e) {
      emit(BannerFormFailure(_sanitizeError(e)));
    }
  }

  Future<void> delete(BannerModel banner) async {
    emit(const BannerFormLoading());
    try {
      await _bannerService.deleteBanner(banner.id);
      await _storageService.deleteFile(banner.imageUrl);
      emit(const BannerFormSuccess('Banner deleted successfully'));
    } catch (e) {
      emit(BannerFormFailure(_sanitizeError(e)));
    }
  }

  String _sanitizeError(Object e) {
    final msg = e.toString();
    if (msg.contains('row-level security') || msg.contains('Unauthorized')) {
      return 'Storage permission denied. Check Supabase bucket policies.';
    }
    return msg;
  }
}
