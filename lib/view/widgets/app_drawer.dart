import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/auth/auth_cubit.dart';
import 'package:gep/cubits/enrolled_students_admin/enrolled_students_cubit.dart';
import 'package:gep/cubits/theme/theme_cubit.dart';
import 'package:gep/router/app_navigation.dart';
import 'package:gep/router/app_routes.dart';
import 'package:gep/services/auth/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.isAdminLoggedIn,
    this.isAdminDashboard = false,
  });

  final bool isAdminLoggedIn;
  final bool isAdminDashboard;

  @override
  Widget build(BuildContext context) {
    final user = AuthService().getCurrentUser();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = theme.scaffoldBackgroundColor;

    return Drawer(
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile Card
            _DrawerHeader(
              user: user,
              isAdminLoggedIn: isAdminLoggedIn,
            ),

            const SizedBox(height: 8),

            // Navigation Items
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (isAdminDashboard) ...[
                    const _SectionHeader(label: 'Navigation'),
                    _DrawerTile(
                      icon: Icons.dashboard_rounded,
                      label: 'Student App View',
                      subtitle: 'Switch to public dashboard',
                      index: 0,
                      onTap: () {
                        Navigator.pop(context);
                        AppNavigation.goAndClearStack(
                          context,
                          AppRoutes.kDashboardRoute,
                        );
                      },
                    ),
                  ] else ...[
                    const _SectionHeader(label: 'Management'),
                    _DrawerTile(
                      icon: Icons.admin_panel_settings_rounded,
                      label: 'Admin Control Center',
                      subtitle: isAdminLoggedIn
                          ? 'Manage portal & students'
                          : 'Admin credentials required',
                      index: 0,
                      onTap: () {
                        Navigator.pop(context);
                        if (isAdminLoggedIn) {
                          AppNavigation.pushReplacement(
                            context,
                            AppRoutes.kAdminDashboardRoute,
                          );
                        } else {
                          AppNavigation.push(
                            context,
                            AppRoutes.kAdminLoginRoute,
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 14),
                    const _SectionHeader(label: 'Appearance'),
                    const _ThemeSegmentedToggle(),

                    const SizedBox(height: 14),
                    const _SectionHeader(label: 'Attendance & Campus'),
                    _DrawerTile(
                      icon: Icons.fact_check_rounded,
                      label: 'My Attendance',
                      subtitle: 'View check-in calendar',
                      index: 1,
                      onTap: () async {
                        final email =
                            FirebaseAuth.instance.currentUser?.email ?? '';
                        final cubit =
                            context.read<EnrolledStudentsAdminCubit>();
                        final studentId =
                            await cubit.getStudentIdByEmail(email);

                        if (!context.mounted) return;
                        context.pop();
                        AppNavigation.push(
                          context,
                          AppRoutes.kStudentAttendanceRoute,
                          queryParameters: {'studentId': studentId},
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    _DrawerTile(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'Scan QR Attendance',
                      subtitle: 'Check in for today',
                      index: 2,
                      onTap: () {
                        Navigator.pop(context);
                        AppNavigation.push(
                          context,
                          AppRoutes.kScanAttendanceRoute,
                        );
                      },
                    ),

                    const SizedBox(height: 14),
                    const _SectionHeader(label: 'Legal & Info'),
                    _DrawerTile(
                      icon: Icons.description_outlined,
                      label: 'Terms & Conditions',
                      subtitle: 'User policies & rules',
                      index: 3,
                      onTap: () {
                        Navigator.pop(context);
                        AppNavigation.push(
                          context,
                          AppRoutes.kTermsAndConditionsRoute,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Logout Tile & Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  _LogoutTile(
                    onTap: () async {
                      Navigator.pop(context);
                      await context.read<AuthCubit>().logout();
                      if (!context.mounted) return;
                      AppNavigation.goAndClearStack(
                        context,
                        AppRoutes.kLoginRoute,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'GEP Portal • v1.0.0',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? Colors.white38
                              : AppColors.lightBodyTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.user, required this.isAdminLoggedIn});

  final User? user;
  final bool isAdminLoggedIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final displayName = user?.displayName ?? 'Welcome';
    final email = user?.email ?? 'Signed in account';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              theme.colorScheme.outline.withValues(alpha: isDark ? 0.3 : 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          theme.colorScheme.primary.withValues(alpha: 0.12),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: user?.photoURL != null
                          ? CachedNetworkImage(
                              imageUrl: user!.photoURL!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person_rounded,
                                color: theme.colorScheme.primary,
                                size: 30,
                              ),
                            )
                          : Icon(
                              Icons.person_rounded,
                              size: 30,
                              color: theme.colorScheme.primary,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.cardColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isAdminLoggedIn
                      ? theme.colorScheme.primary.withValues(alpha: 0.14)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAdminLoggedIn
                        ? theme.colorScheme.primary.withValues(alpha: 0.4)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAdminLoggedIn
                          ? Icons.shield_rounded
                          : Icons.school_rounded,
                      size: 13,
                      color: isAdminLoggedIn
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isAdminLoggedIn ? 'ADMIN' : 'STUDENT',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isAdminLoggedIn
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.05, end: 0);
  }
}

class _ThemeSegmentedToggle extends StatelessWidget {
  const _ThemeSegmentedToggle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isDarkMode = state.themeMode == ThemeMode.dark;

        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline
                  .withValues(alpha: isDark ? 0.3 : 0.6),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (isDarkMode) {
                      context.read<ThemeCubit>().toggleTheme();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !isDarkMode
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.light_mode_rounded,
                          size: 16,
                          color: !isDarkMode
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Light',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: !isDarkMode
                                ? Colors.white
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (!isDarkMode) {
                      context.read<ThemeCubit>().toggleTheme();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.dark_mode_rounded,
                          size: 16,
                          color: isDarkMode
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Dark',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.index,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                theme.colorScheme.outline.withValues(alpha: isDark ? 0.25 : 0.5),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (40 * index).ms, duration: 250.ms)
        .slideX(begin: 0.04, end: 0);
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.25),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  size: 18,
                  color: AppColors.error,
                ),
                const SizedBox(width: 10),
                Text(
                  'Sign Out',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
