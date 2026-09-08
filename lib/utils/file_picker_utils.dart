import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FilePickerUtils {
  static Future<File?> pickPdfFile() async {
    try {
      final PlatformFile? file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (file != null && file.path != null && file.path!.isNotEmpty) {
        final f = File(file.path!);
        if (await f.exists()) {
          return f;
        }
      }
      return null;
    } catch (e) {
      log('Error picking PDF file: $e');
      return null;
    }
  }
}
