import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/utils/file_picker_utils.dart';
import 'note_upload_state.dart';

class NoteUploadCubit extends Cubit<NoteUploadState> {
  NoteUploadCubit() : super(const NoteUploadState());

  Future<void> pickFile() async {
    final file = await FilePickerUtils.pickPdfFile();
    if (file != null) {
      final sizeInBytes = await file.length();
      final sizeFormatted = sizeInBytes < 1024 * 1024
          ? '${(sizeInBytes / 1024).toStringAsFixed(1)} KB'
          : '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      final fileName = file.path.split('/').last;

      emit(state.copyWith(
        selectedFile: () => file,
        fileName: () => fileName,
        fileSize: () => sizeFormatted,
      ));
    }
  }

  void clearFile() {
    emit(const NoteUploadState());
  }
}
