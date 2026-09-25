import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  ImageUtils._();

  /// Picks an image from the specified [source].
  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: maxWidth ?? 1920,
        maxHeight: maxHeight ?? 1920,
        imageQuality: imageQuality ?? 90,
      );
      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Opens the cropper UI for an image [File].
  static Future<File?> cropImage({
    required File imageFile,
    required BuildContext context,
    CropAspectRatio? aspectRatio,
    List<CropAspectRatioPreset>? aspectRatioPresets,
  }) async {
    try {
      final theme = Theme.of(context);
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: aspectRatio,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: theme.colorScheme.primary,
            toolbarWidgetColor: theme.colorScheme.onPrimary,
            activeControlsWidgetColor: theme.colorScheme.primary,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: aspectRatio != null,
            aspectRatioPresets:
                aspectRatioPresets ??
                [
                  CropAspectRatioPreset.ratio16x9,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: aspectRatio != null,
            aspectRatioPresets:
                aspectRatioPresets ??
                [
                  CropAspectRatioPreset.ratio16x9,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                ],
          ),
        ],
      );

      if (croppedFile == null) return null;
      return File(croppedFile.path);
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }

  /// Pipeline: Pick -> Crop -> Resize in a single process.
  static Future<File?> pickCropAndResizeImage({
    required BuildContext context,
    ImageSource source = ImageSource.gallery,
    required int targetWidth,
    required int targetHeight,
    CropAspectRatio? aspectRatio,
  }) async {
    final pickedFile = await pickImage(source: source);
    if (pickedFile == null) return null;

    if (!context.mounted) return null;

    final croppedFile = await cropImage(
      imageFile: pickedFile,
      context: context,
      aspectRatio: aspectRatio,
    );
    if (croppedFile == null) return null;

    return await resizeImageFile(
      imageFile: croppedFile,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );
  }

  /// Resizes an image file using high-quality hardware-accelerated Canvas rendering.
  static Future<File?> resizeImageFile({
    required File imageFile,
    required int targetWidth,
    required int targetHeight,
    String fileNamePrefix = 'processed_image',
  }) async {
    try {
      final rawBytes = await imageFile.readAsBytes();
      final img = await decodeImageFromList(rawBytes);

      final ui.Image resizedImage = await _resizeImageCanvas(
        img,
        targetWidth,
        targetHeight,
      );

      final byteData = await resizedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return null;

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await tempFile.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );

      return tempFile;
    } catch (e) {
      debugPrint('Error resizing image: $e');
      return null;
    }
  }

  static Future<ui.Image> _resizeImageCanvas(
    ui.Image image,
    int targetWidth,
    int targetHeight,
  ) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble()),
      Paint()..filterQuality = FilterQuality.high,
    );

    final picture = pictureRecorder.endRecording();
    return picture.toImage(targetWidth, targetHeight);
  }
}
