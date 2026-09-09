import 'package:flutter/material.dart';

// Images
class Images {
  static const siginLight = "assets/images/signin_light.png";
  static const signinDark = "assets/images/signin_dark.png";
}

class AppIcons {
  static const gepLogo = "assets/icons/icon_foreground.png";
  static const gepLogoLight = "assets/icons/icon_navy.png";
  static const gepLogoDark = "assets/icons/icon_black.png";
  static const siginLight = "assets/icons/signin_light.png";
  static const signinDark = "assets/icons/signin_dark.png";
}

class AppLotties {
  static const aboutMe = "assets/lotties/about_me.json";
  static const admissions = "assets/lotties/admissions.json";
  static const attendance = "assets/lotties/attendance.json";
  static const qrCode = "assets/lotties/qr_code.json";
  static const banners = "assets/lotties/banners.json";
  static const courses = "assets/lotties/courses.json";
  static const location = "assets/lotties/location.json";
  static const notes = "assets/lotties/notes.json";
  static const playlist = "assets/lotties/playlist.json";
  static const shift = "assets/lotties/shift.json";
  static const students = "assets/lotties/students.json";
  static const terms = "assets/lotties/terms.json";
  static const updates = "assets/lotties/updates.json";
  static const youtube = "assets/lotties/youtube.json";
}

// Colors
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF0A2137); // Navy (brand color)
  static const Color secondary = Color(0xFF26A69A); // Teal
  static const Color accent = Color(0xFFFFC107); // Amber

  // Light Theme Colors
  static const Color lightScaffoldBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightAppBarBackground = Color(0xFFF8FAFC);
  static const Color lightAppBarForeground = Color(0xFF0F172A);
  static const Color lightBodyText = Color(0xFF0F172A); // Slate 900
  static const Color lightBodyTextSecondary = Color(0xFF64748B); // Slate 500
  static const Color lightCard = Color(0xFFFFFFFF); // Pure white card
  static const Color lightIcon = Color(0xFF0F172A);
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color lightDivider = Color(0xFFE2E8F0);
  static const Color lightNeutral = Color(0xFFF1F5F9); // Slate 100

  // Dark Theme Colors (Updated Slate Grey palette to fix black pitch issue)
  static const Color darkScaffoldBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkAppBarBackground = Color(0xFF0F172A);
  static const Color darkAppBarForeground = Color(0xFFF8FAFC);
  static const Color darkBodyText = Color(0xFFF8FAFC); // Slate 50
  static const Color darkBodyTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkCard = Color(0xFF1E293B); // Slate 800 surface
  static const Color darkIcon = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155); // Slate 700 border
  static const Color darkDivider = Color(0xFF334155);
  static const Color darkNeutral = Color(
    0xFF334155,
  ); // Slate 700 neutral surface

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color error = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color info = Color(0xFF3B82F6); // Blue

  // Additional Colors
  static const Color highlightYellow = Color(0xFFFFF59D);

  // Random Colors
  static const List<Color> randomColors = [
    Color(0xFF0A2137), // Navy
    Color(0xFF26A69A), // Teal
    Color(0xFFF57C00), // Dark orange
    Color(0xFF7B1FA2), // Purple
    Color(0xFF388E3C), // Green
    Color(0xFF0277BD), // Light blue
    Color(0xFFD32F2F), // Red
    Color(0xFF5D4037), // Brown
    Color(0xFF455A64), // Blue grey
    Color(0xFF00796B), // Dark teal
  ];
}

// Gradients
class AppGradients {
  static const LinearGradient notes = LinearGradient(
    colors: [Color(0xFF6A1B9A), Color(0xFF1E88E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient courses = LinearGradient(
    colors: [Color(0xFF00BCD4), Color(0xFF3F51B5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient updates = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF009688)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient admissions = LinearGradient(
    colors: [Color(0xFFFF4081), Color(0xFFFF5722)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient students = LinearGradient(
    colors: [Color(0xFFFFA000), Color(0xFFFF5722)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aboutMe = LinearGradient(
    colors: [Color(0xFF3F51B5), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient terms = LinearGradient(
    colors: [Color(0xFF009688), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppConstants {
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 14.0;
  static const double defaultBorderWidth = 1.0;
  static const double defaultIconSize = 24.0;
  static const double defaultElevation = 0.0;
}
