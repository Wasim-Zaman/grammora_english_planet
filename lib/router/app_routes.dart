/// Route names for navigation
class AppRoutes {
  // Auth routes
  static const String kLoginRoute = "login";
  static const String kLoginRoutePath = "/login";

  static const String kAdminLoginRoute = "admin-login";
  static const String kAdminLoginRoutePath = "/admin-login";

  // Main dashboard routes
  static const String kDashboardRoute = "dashboard";
  static const String kDashboardRoutePath = "/dashboard";

  static const String kAdminDashboardRoute = "admin-dashboard";
  static const String kAdminDashboardRoutePath = "/admin-dashboard";

  static const String kSplashRoute = "splash";
  static const String kSplashRoutePath = "/";

  // User dashboard screens
  static const String kAboutMeRoute = "about-me";
  static const String kAboutMeRoutePath = "/about-me";

  static const String kAdmissionsRoute = "admissions";
  static const String kAdmissionsRoutePath = "/admissions";

  static const String kCoursesOutlinesRoute = "courses-outlines";
  static const String kCoursesOutlinesRoutePath = "/courses-outlines";

  static const String kEnrolledStudentsRoute = "enrolled-students";
  static const String kEnrolledStudentsRoutePath = "/enrolled-students";

  static const String kNotesRoute = "notes";
  static const String kNotesRoutePath = "/notes";

  static const String kNotesCategoriesRoute = "notes-categories";
  static const String kNotesCategoriesRoutePath = "/notes-categories";

  static const String kPlaylistsRoute = "playlists";
  static const String kPlaylistsRoutePath = "/playlists";

  static const String kUpdatesRoute = "updates";
  static const String kUpdatesRoutePath = "/updates";

  static const String kTermsAndConditionsRoute = "terms-and-conditions";
  static const String kTermsAndConditionsRoutePath = "/terms-and-conditions";

  // PDF viewer
  static const String kPdfViewerRoute = "pdf-viewer";
  static const String kPdfViewerRoutePath = "/pdf-viewer";

  // Resume viewer
  static const String kFullScreenResumeRoute = "full-screen-resume";
  static const String kFullScreenResumeRoutePath = "/full-screen-resume";
  static const String kYouTubeChannelRoute = "youtube-channel";
  static const String kYouTubeChannelRoutePath = "/youtube-channel";

  // Playlist detail
  static const String kPlaylistDetailRoute = "playlist-detail";
  static const String kPlaylistDetailRoutePath = "/playlist-detail";

  // Student details
  static const String kStudentDetailsRoute = "student-details";
  static const String kStudentDetailsRoutePath = "/student-details";

  // Admin management routes
  static const String kManageAboutMeRoute = "manage-about-me";
  static const String kManageAboutMeRoutePath = "/admin/manage-about-me";

  static const String kManageBannerRoute = "manage-banner";
  static const String kManageBannerRoutePath = "/admin/manage-banner";

  static const String kManageCoursesRoute = "manage-courses";
  static const String kManageCoursesRoutePath = "/admin/manage-courses";

  static const String kEnrollStudentsManagementRoute =
      "enroll-students-management";
  static const String kEnrollStudentsManagementRoutePath =
      "/admin/enroll-students-management";

  static const String kAddStudentRoute = "add-student";
  static const String kAddStudentRoutePath = "/admin/add-student";

  static const String kEditStudentRoute = "edit-student";
  static const String kEditStudentRoutePath = "/admin/edit-student";

  static const String kAdminNotesCategoriesRoute = "admin-notes-categories";
  static const String kAdminNotesCategoriesRoutePath =
      "/admin/notes-categories";

  static const String kAddNotesRoute = "add-notes";
  static const String kAddNotesRoutePath = "/admin/add-notes";

  static const String kPlaylistsManagementRoute = "playlists-management";
  static const String kPlaylistsManagementRoutePath =
      "/admin/playlists-management";

  static const String kAddPlaylistRoute = "add-playlist";
  static const String kAddPlaylistRoutePath = "/admin/add-playlist";

  static const String kUpdatesManagementRoute = "updates-management";
  static const String kUpdatesManagementRoutePath = "/admin/updates-management";

  static const String kAdminAdmissionsRoute = "admin-admissions";
  static const String kAdminAdmissionsRoutePath = "/admin/admissions";

  // Attendance module routes
  static const String kManageShiftsRoute = "manage-shifts";
  static const String kManageShiftsRoutePath = "/admin/manage-shifts";

  static const String kQrAttendanceRoute = "qr-attendance";
  static const String kQrAttendanceRoutePath = "/admin/qr-attendance";

  static const String kAdminAttendanceRecordsRoute = "admin-attendance-records";
  static const String kAdminAttendanceRecordsRoutePath = "/admin/attendance-records";

  static const String kScanAttendanceRoute = "scan-attendance";
  static const String kScanAttendanceRoutePath = "/scan-attendance";

  static const String kStudentAttendanceRoute = "student-attendance";
  static const String kStudentAttendanceRoutePath = "/student-attendance";
}
