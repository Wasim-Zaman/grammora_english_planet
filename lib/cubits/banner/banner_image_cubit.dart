import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/utils/image_utils.dart';
import 'package:image_cropper/image_cropper.dart';

part 'banner_image_state.dart';

class BannerImageCubit extends Cubit<BannerImageState> {
  BannerImageCubit() : super(const BannerImageInitial());

  Future<void> pickAndProcessBanner(
    BuildContext context, {
    int targetWidth = 1200,
    int targetHeight = 480,
  }) async {
    emit(const BannerImageProcessing());

    final processedImage = await ImageUtils.pickCropAndResizeImage(
      context: context,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
      // Default standard banner ratio (1200 / 480 = 2.5 ratio)
      aspectRatio: const CropAspectRatio(ratioX: 5, ratioY: 2),
    );

    if (processedImage != null) {
      emit(BannerImageSuccess(processedImage));
    } else {
      emit(const BannerImageInitial());
    }
  }

  void reset() {
    emit(const BannerImageInitial());
  }
}
