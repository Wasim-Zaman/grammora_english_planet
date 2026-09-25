import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/utils/image_utils.dart';
import 'package:image_cropper/image_cropper.dart';

abstract class StudentSpotlightImageState extends Equatable {
  const StudentSpotlightImageState();

  @override
  List<Object?> get props => [];
}

class StudentSpotlightImageInitial extends StudentSpotlightImageState {
  const StudentSpotlightImageInitial();
}

class StudentSpotlightImageProcessing extends StudentSpotlightImageState {
  const StudentSpotlightImageProcessing();
}

class StudentSpotlightImageSuccess extends StudentSpotlightImageState {
  final File imageFile;
  const StudentSpotlightImageSuccess(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

class StudentSpotlightImageFailure extends StudentSpotlightImageState {
  final String error;
  const StudentSpotlightImageFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class StudentSpotlightImageCubit extends Cubit<StudentSpotlightImageState> {
  StudentSpotlightImageCubit() : super(const StudentSpotlightImageInitial());

  Future<void> pickAndProcessPhoto(BuildContext context) async {
    if (isClosed) return;
    emit(const StudentSpotlightImageProcessing());

    try {
      final processedImage = await ImageUtils.pickCropAndResizeImage(
        context: context,
        targetWidth: 800,
        targetHeight: 800,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      );

      if (isClosed) return;

      if (processedImage != null) {
        emit(StudentSpotlightImageSuccess(processedImage));
      } else {
        emit(const StudentSpotlightImageInitial());
      }
    } catch (e) {
      if (isClosed) return;
      emit(StudentSpotlightImageFailure(e.toString()));
    }
  }

  void reset() {
    if (isClosed) return;
    emit(const StudentSpotlightImageInitial());
  }
}
