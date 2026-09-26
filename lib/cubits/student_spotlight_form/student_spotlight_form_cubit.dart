import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/student_spotlight.dart';
import '../../services/storage/storage_service.dart';
import '../../services/student_spotlight/student_spotlight_service.dart';

import 'student_spotlight_form_state.dart';

class StudentSpotlightFormCubit extends Cubit<StudentSpotlightFormState> {
  final StudentSpotlightService _spotlightService;
  final StorageService _storageService;

  StudentSpotlightFormCubit(this._spotlightService, this._storageService)
      : super(const StudentSpotlightFormInitial());

  void reset() => emit(const StudentSpotlightFormInitial());

  Future<void> save({
    required String studentName,
    required String awardTitle,
    required String period,
    String courseOrBatch = '',
    String quoteOrMessage = '',
    String achievementHighlights = '',
    bool isFeatured = true,
    File? imageFile,
    StudentSpotlightModel? existingSpotlight,
  }) async {
    final cleanName = studentName.trim();
    if (cleanName.isEmpty) {
      emit(const StudentSpotlightFormFailure('Please enter student name'));
      return;
    }

    final cleanPeriod = period.trim();
    if (cleanPeriod.isEmpty) {
      emit(const StudentSpotlightFormFailure('Please specify the month/period (e.g. October 2026)'));
      return;
    }

    if (imageFile == null &&
        (existingSpotlight == null || existingSpotlight.imageUrl.isEmpty)) {
      emit(const StudentSpotlightFormFailure('Please select a student photo'));
      return;
    }

    emit(const StudentSpotlightFormLoading());
    try {
      String imageUrl = existingSpotlight?.imageUrl ?? '';

      if (imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
        final filePath = 'student_spotlights/$fileName';
        imageUrl = await _storageService.uploadFile(filePath, imageFile);

        if (existingSpotlight != null &&
            existingSpotlight.imageUrl.isNotEmpty) {
          await _storageService.deleteFile(existingSpotlight.imageUrl);
        }
      }

      final spotlight = StudentSpotlightModel(
        id: existingSpotlight?.id ?? '',
        studentName: cleanName,
        awardTitle: awardTitle.trim().isEmpty ? 'Student of the Month' : awardTitle.trim(),
        period: cleanPeriod,
        courseOrBatch: courseOrBatch.trim(),
        imageUrl: imageUrl,
        quoteOrMessage: quoteOrMessage.trim(),
        achievementHighlights: achievementHighlights.trim(),
        isFeatured: isFeatured,
      );

      if (existingSpotlight == null) {
        await _spotlightService.addSpotlight(spotlight);
        emit(const StudentSpotlightFormSuccess('Star student added successfully'));
      } else {
        await _spotlightService.updateSpotlight(existingSpotlight.id, spotlight);
        emit(const StudentSpotlightFormSuccess('Star student updated successfully'));
      }
    } catch (e) {
      emit(StudentSpotlightFormFailure(_sanitizeError(e)));
    }
  }

  Future<void> delete(StudentSpotlightModel spotlight) async {
    emit(const StudentSpotlightFormLoading());
    try {
      await _spotlightService.deleteSpotlight(spotlight.id);
      if (spotlight.imageUrl.isNotEmpty) {
        await _storageService.deleteFile(spotlight.imageUrl);
      }
      emit(const StudentSpotlightFormSuccess('Star student deleted successfully'));
    } catch (e) {
      emit(StudentSpotlightFormFailure(_sanitizeError(e)));
    }
  }

  String _sanitizeError(Object e) {
    final msg = e.toString();
    if (msg.contains('row-level security') || msg.contains('Unauthorized')) {
      return 'Permission denied. Please verify Supabase policies.';
    }
    return msg;
  }
}
