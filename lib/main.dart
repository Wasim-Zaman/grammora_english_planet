import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gep/core/constants/env.dart';
import 'package:gep/cubits/admin/admin_cubit.dart';
import 'package:gep/cubits/admissions/admissions_cubit.dart';
import 'package:gep/cubits/auth/auth_cubit.dart';
import 'package:gep/cubits/banners/banners_cubit.dart';
import 'package:gep/cubits/courses/courses_cubit.dart';
import 'package:gep/cubits/enrolled_students_admin/enrolled_students_cubit.dart';
import 'package:gep/cubits/notes_categories/notes_categories_cubit.dart';
import 'package:gep/cubits/attendance_admin/attendance_admin_cubit.dart';
import 'package:gep/cubits/shifts/shifts_cubit.dart';
import 'package:gep/cubits/student_attendance/student_attendance_cubit.dart';
import 'package:gep/cubits/theme/theme_cubit.dart';
import 'package:gep/cubits/updates_admin/updates_admin_cubit.dart';
import 'package:gep/cubits/user_admissions/user_admissions_cubit.dart';
import 'package:gep/cubits/user_courses/user_courses_cubit.dart';
import 'package:gep/cubits/user_notes/user_notes_cubit.dart';
import 'package:gep/cubits/user_students/user_students_cubit.dart';
import 'package:gep/cubits/user_updates/user_updates_cubit.dart';
import 'package:gep/services/attendance/attendance_service.dart';
import 'package:gep/services/shifts/shifts_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gep/services/about_me/about_me_service.dart';
import 'package:gep/services/admissions/admissions_services.dart';
import 'package:gep/services/analytics/analytics_service.dart';
import 'package:gep/services/auth/auth_admin_service.dart';
import 'package:gep/services/banner/banner_service.dart';
import 'package:gep/services/courses_outline/courses_outline_service.dart';
import 'package:gep/services/enrolled_students/enrolled_students_services.dart';
import 'package:gep/services/notes/notes_service.dart';
import 'package:gep/services/storage/storage_service.dart';
import 'package:gep/services/updates/updates_services.dart';

import 'firebase_options.dart';
import 'gep_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  final savedTheme = await ThemeCubit.loadSavedTheme();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AdminCubit(
            NotesService(),
            StorageService(),
            CoursesOutlineService(),
            AdmissionsService(),
            BannerService(),
            AboutMeService(),
            UpdatesServices(),
            EnrolledStudentsServices(AnalyticsService()),
          ),
        ),
        BlocProvider(create: (context) => AuthCubit(AdminAuthService())),
        BlocProvider(create: (context) => NotesCategoriesCubit(NotesService())),
        BlocProvider(create: (context) => BannersCubit(BannerService())),
        BlocProvider(create: (context) => AdmissionsCubit(AdmissionsService())),
        BlocProvider(create: (context) => UpdatesAdminCubit(UpdatesServices())),
        BlocProvider(create: (context) => EnrolledStudentsAdminCubit(EnrolledStudentsServices(AnalyticsService()))),
        BlocProvider(create: (context) => CoursesCubit(CoursesOutlineService())),
        BlocProvider(create: (context) => UserNotesCubit(NotesService())),
        BlocProvider(create: (context) => UserAdmissionsCubit(AdmissionsService())),
        BlocProvider(create: (context) => UserCoursesCubit(CoursesOutlineService())),
        BlocProvider(create: (context) => UserUpdatesCubit(UpdatesServices())),
        BlocProvider(create: (context) => UserStudentsCubit(EnrolledStudentsServices(AnalyticsService()))),
        BlocProvider(create: (context) => ShiftsCubit(ShiftsService())),
        BlocProvider(create: (context) => AttendanceAdminCubit(AttendanceService())),
        BlocProvider(create: (context) => StudentAttendanceCubit(AttendanceService())),
        BlocProvider(create: (context) => ThemeCubit(savedTheme)),
      ],
      child: MyApp(observer: observer),
    ),
  );
}
