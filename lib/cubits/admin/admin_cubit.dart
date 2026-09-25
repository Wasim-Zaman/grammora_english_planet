import 'dart:developer';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/models/about_me.dart';
import 'package:gep/models/admission_announcement.dart';
import 'package:gep/models/banner.dart';
import 'package:gep/models/course_outline.dart';
import 'package:gep/models/enrolled_students.dart';
import 'package:gep/models/note.dart';
import 'package:gep/models/updates.dart';
import 'package:gep/services/about_me/about_me_service.dart';
import 'package:gep/services/admissions/admissions_services.dart';
import 'package:gep/services/banner/banner_service.dart';
import 'package:gep/services/courses_outline/courses_outline_service.dart';
import 'package:gep/services/enrolled_students/enrolled_students_services.dart';
import 'package:gep/services/notes/notes_service.dart';
import 'package:gep/services/storage/storage_service.dart';
import 'package:gep/services/updates/updates_services.dart';

part 'admin_states.dart';

class AdminCubit extends Cubit<AdminState> {
  final NotesService _notesService;
  final StorageService _storageService;
  final CoursesOutlineService _coursesOutlineService;
  final AdmissionsService _admissionsService;
  final BannerService _bannerService;
  final AboutMeService _aboutMeService;
  final UpdatesServices _updatesService;
  final EnrolledStudentsServices _enrolledStudentsServices;

  AdminCubit(
    this._notesService,
    this._storageService,
    this._coursesOutlineService,
    this._admissionsService,
    this._bannerService,
    this._aboutMeService,
    this._updatesService,
    this._enrolledStudentsServices,
  ) : super(AdminInitial());

  Future<void> addCategory(String category) async {
    emit(AdminLoading());
    try {
      await _notesService.addCategory(category);
      emit(AdminSuccess('Category added successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> deleteCategory(String category) async {
    emit(AdminLoading());
    try {
      // Delete the category and all associated notes from Supabase
      await _notesService.deleteCategory(category);

      // Delete the entire folder for the category from Supabase Storage
      await _storageService.deleteFolder('notes/$category');

      emit(
        AdminSuccess('Category and all associated notes deleted successfully'),
      );
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> uploadNote(String category, String title, File file) async {
    emit(AdminLoading());
    try {
      final trimmedCategory = category.trim();
      if (trimmedCategory.isEmpty) {
        emit(AdminFailure('Category cannot be empty'));
        return;
      }
      final trimmedTitle = title.trim();
      if (trimmedTitle.isEmpty) {
        emit(AdminFailure('Title cannot be empty'));
        return;
      }

      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = 'notes/$trimmedCategory/$fileName';
      final String downloadUrl = await _storageService.uploadFile(
        filePath,
        file,
        contentType: 'application/pdf',
      );
      await _notesService.addNote(trimmedCategory, trimmedTitle, downloadUrl);
      emit(AdminSuccess('Note uploaded successfully'));
    } catch (e) {
      log('Error uploading note: $e');
      emit(AdminFailure(e.toString()));
    }
  }

  Stream<List<String>> getCategoriesStream() {
    return _notesService.getCategoriesStream();
  }

  Stream<List<Note>> getNotesStream(String category) {
    return _notesService.getNotesStream(category);
  }

  Future<void> deleteNote(
    String category,
    String noteId,
    String fileUrl,
  ) async {
    emit(AdminLoading());
    try {
      await _notesService.deleteNote(category, noteId);
      await _storageService.deleteFile(fileUrl);
      emit(AdminSuccess('Note deleted successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  // Courses Outlines
  Stream<List<Course>> getCoursesStream() {
    return _coursesOutlineService.getCoursesStream();
  }

  Future<void> addCourse(Course course) async {
    emit(AdminLoading());
    try {
      await _coursesOutlineService.addCourse(course);
      emit(AdminSuccess('Course added successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> updateCourse(String courseId, Course course) async {
    emit(AdminLoading());
    try {
      await _coursesOutlineService.updateCourse(courseId, course);
      emit(AdminSuccess('Course updated successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> deleteCourse(String courseId) async {
    emit(AdminLoading());
    try {
      await _coursesOutlineService.deleteCourse(courseId);
      emit(AdminSuccess('Course deleted successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  // Admissions
  Stream<List<AdmissionAnnouncement>> getAdmissionAnnouncementsStream() {
    return _admissionsService.getAnnouncementsStream();
  }

  Future<void> addAdmissionAnnouncement(
    AdmissionAnnouncement announcement,
  ) async {
    emit(AdminLoading());
    try {
      await _admissionsService.addAnnouncement(announcement);
      emit(AdminSuccess('Announcement added successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> updateAdmissionAnnouncement(
    AdmissionAnnouncement announcement,
  ) async {
    emit(AdminLoading());
    try {
      await _admissionsService.updateAnnouncement(announcement);
      emit(AdminSuccess('Announcement updated successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> deleteAdmissionAnnouncement(String id) async {
    emit(AdminLoading());
    try {
      await _admissionsService.deleteAnnouncement(id);
      emit(AdminSuccess('Announcement deleted successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  // Banner management methods
  Stream<List<BannerModel>> getBannersStream() {
    return _bannerService.getBannersStream();
  }

  Future<void> addBanner(String title, File imageFile) async {
    emit(AdminLoading());
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final String filePath = 'banners/$fileName';
      final String imageUrl = await _storageService.uploadFile(
        filePath,
        imageFile,
      );
      final BannerModel banner = BannerModel(
        id: '',
        title: title,
        imageUrl: imageUrl,
      );
      await _bannerService.addBanner(banner);
      emit(AdminSuccess('Banner added successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
      rethrow;
    }
  }

  Future<void> updateBanner(BannerModel banner, File? newImageFile) async {
    emit(AdminLoading());
    try {
      String imageUrl = banner.imageUrl;
      if (newImageFile != null) {
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
        final String filePath = 'banners/$fileName';
        imageUrl = await _storageService.uploadFile(filePath, newImageFile);
        await _storageService.deleteFile(banner.imageUrl);
      }
      final BannerModel updatedBanner = banner.copyWith(imageUrl: imageUrl);
      await _bannerService.updateBanner(banner.id, updatedBanner);
      emit(AdminSuccess('Banner updated successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
      rethrow;
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    emit(AdminLoading());
    try {
      final BannerModel banner = await _bannerService.getBanner(bannerId);
      await _bannerService.deleteBanner(bannerId);
      await _storageService.deleteFile(banner.imageUrl);
      emit(AdminSuccess('Banner deleted successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
      rethrow;
    }
  }

  // About Me management methods
  Future<void> updateAboutMe(
    AboutMe aboutMe, {
    File? profileImage,
    File? resume,
  }) async {
    emit(AdminLoading());
    try {
      String? profileImageUrl = aboutMe.profileImageUrl;
      String? resumeUrl = aboutMe.resumeUrl;

      if (profileImage != null) {
        profileImageUrl = await _storageService.uploadFile(
          'profile_images/admin_profile.jpg',
          profileImage,
        );
      }

      if (resume != null) {
        resumeUrl = await _storageService.uploadFile(
          'resumes/admin_resume.pdf',
          resume,
        );
      }

      final updatedAboutMe = aboutMe.copyWith(
        profileImageUrl: profileImageUrl,
        resumeUrl: resumeUrl,
      );

      await _aboutMeService.updateAboutMeData(updatedAboutMe);
      emit(AdminSuccess('About Me information updated successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Stream<AboutMe> getAboutMeStream() {
    return _aboutMeService.getAboutMeStream();
  }

  // Updates management methods
  Stream<List<Updates>> getUpdatesStream() {
    return _updatesService.getUpdatesStream();
  }

  Future<void> addUpdates(Updates update) async {
    emit(AdminLoading());
    try {
      await _updatesService.addUpdate(update);
      emit(AdminSuccess('Update added successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> updateUpdates(String updateId, Updates update) async {
    emit(AdminLoading());
    try {
      await _updatesService.updateUpdate(updateId, update);
      emit(AdminSuccess('Update modified successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> deleteUpdates(String updateId) async {
    emit(AdminLoading());
    try {
      await _updatesService.deleteUpdate(updateId);
      emit(AdminSuccess('Update deleted successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  // Enrolled Students management methods
  Stream<List<EnrolledStudent>> getEnrolledStudentsStream() {
    return _enrolledStudentsServices.getEnrolledStudentsStream();
  }

  Future<void> addEnrolledStudent(EnrolledStudent student) async {
    emit(AdminLoading());
    try {
      await _enrolledStudentsServices.addStudent(student);
      emit(AdminSuccess('Student enrolled successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> updateEnrolledStudent(
    String studentId,
    EnrolledStudent student,
  ) async {
    emit(AdminLoading());
    try {
      await _enrolledStudentsServices.updateStudent(studentId, student);
      emit(AdminSuccess('Student information updated successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> deleteEnrolledStudent(String studentId) async {
    emit(AdminLoading());
    try {
      await _enrolledStudentsServices.deleteStudent(studentId);
      emit(AdminSuccess('Student removed successfully'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<EnrolledStudent?> getEnrolledStudentById(String studentId) async {
    try {
      return await _enrolledStudentsServices.getStudentById(studentId);
    } catch (e) {
      emit(AdminFailure(e.toString()));
      return null;
    }
  }

  Future<List<EnrolledStudent>> getEnrolledStudentsByLevel(String level) async {
    try {
      return await _enrolledStudentsServices.getStudentsByLevel(level);
    } catch (e) {
      emit(AdminFailure(e.toString()));
      return [];
    }
  }
}
