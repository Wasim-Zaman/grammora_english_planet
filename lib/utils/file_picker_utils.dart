import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FilePickerUtils {
  static Future<File?> pickPdfFile() async {
    final PlatformFile? file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (file != null && file.path != null) {
      return File(file.path!);
    }
    return null;
  }
}
