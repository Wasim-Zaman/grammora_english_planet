import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/env.dart';
import 'cubits/admin/admin_cubit.dart';
import 'cubits/admissions/admissions_cubit.dart';
import 'cubits/attendance_admin/attendance_admin_cubit.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/banners/banners_cubit.dart';
import 'cubits/courses/courses_cubit.dart';
import 'cubits/enrolled_students_admin/enrolled_students_cubit.dart';
import 'cubits/notes_categories/notes_categories_cubit.dart';
import 'cubits/shifts/shifts_cubit.dart';
import 'cubits/student_attendance/student_attendance_cubit.dart';
import 'cubits/theme/theme_cubit.dart';
import 'cubits/updates_admin/updates_admin_cubit.dart';
import 'cubits/user_admissions/user_admissions_cubit.dart';
import 'cubits/user_courses/user_courses_cubit.dart';
import 'cubits/user_notes/user_notes_cubit.dart';
import 'cubits/user_students/user_students_cubit.dart';
import 'cubits/user_updates/user_updates_cubit.dart';
import 'firebase_options.dart';
import 'gep_app.dart';
import 'services/about_me/about_me_service.dart';
import 'services/admissions/admissions_services.dart';
import 'services/analytics/analytics_service.dart';
import 'services/attendance/attendance_service.dart';
import 'services/auth/auth_admin_service.dart';
import 'services/banner/banner_service.dart';
import 'services/courses_outline/courses_outline_service.dart';
import 'services/enrolled_students/enrolled_students_services.dart';
import 'services/notes/notes_service.dart';
import 'services/shifts/shifts_service.dart';
import 'services/storage/storage_service.dart';
import 'services/updates/updates_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );

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
        BlocProvider(
          create: (context) => EnrolledStudentsAdminCubit(
            EnrolledStudentsServices(AnalyticsService()),
          ),
        ),
        BlocProvider(
          create: (context) => CoursesCubit(CoursesOutlineService()),
        ),
        BlocProvider(create: (context) => UserNotesCubit(NotesService())),
        BlocProvider(
          create: (context) => UserAdmissionsCubit(AdmissionsService()),
        ),
        BlocProvider(
          create: (context) => UserCoursesCubit(CoursesOutlineService()),
        ),
        BlocProvider(create: (context) => UserUpdatesCubit(UpdatesServices())),
        BlocProvider(
          create: (context) =>
              UserStudentsCubit(EnrolledStudentsServices(AnalyticsService())),
        ),
        BlocProvider(create: (context) => ShiftsCubit(ShiftsService())),
        BlocProvider(
          create: (context) => AttendanceAdminCubit(AttendanceService()),
        ),
        BlocProvider(
          create: (context) => StudentAttendanceCubit(AttendanceService()),
        ),
        BlocProvider(create: (context) => ThemeCubit(savedTheme)),
      ],
      child: MyApp(observer: observer),
    ),
  );
}
