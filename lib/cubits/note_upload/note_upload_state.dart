import 'dart:io';
import 'package:equatable/equatable.dart';

class NoteUploadState extends Equatable {
  final File? selectedFile;
  final String? fileName;
  final String? fileSize;

  const NoteUploadState({
    this.selectedFile,
    this.fileName,
    this.fileSize,
  });

  NoteUploadState copyWith({
    File? Function()? selectedFile,
    String? Function()? fileName,
    String? Function()? fileSize,
  }) {
    return NoteUploadState(
      selectedFile:
          selectedFile != null ? selectedFile() : this.selectedFile,
      fileName: fileName != null ? fileName() : this.fileName,
      fileSize: fileSize != null ? fileSize() : this.fileSize,
    );
  }

  @override
  List<Object?> get props => [selectedFile, fileName, fileSize];
}
