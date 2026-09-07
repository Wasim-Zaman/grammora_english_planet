import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/constants.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/enrolled_students_admin/enrolled_students_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../router/app_navigation.dart';
import '../../router/app_routes.dart';
import '../../services/auth/auth_service.dart';

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

    final backgroundColor = isDark
        ? AppColors.darkScaffoldBackground
        : AppColors.lightScaffoldBackground;

    final List<Widget> tiles = [];
    int index = 0;

    if (isAdminDashboard) {
      tiles.add(
        _DrawerTile(
          icon: Icons.dashboard_outlined,
          label: 'User App',
          index: index++,
          onTap: () {
            Navigator.pop(context);
            AppNavigation.goAndClearStack(context, AppRoutes.kDashboardRoute);
          },
        ),
      );
    } else {
      tiles.add(const _SectionHeader(label: 'Account'));
      tiles.add(
        _DrawerTile(
          icon: Icons.admin_panel_settings_outlined,
          label: 'Admin Panel',
          index: index++,
          onTap: () {
            Navigator.pop(context);
            if (isAdminLoggedIn) {
              AppNavigation.pushReplacement(
                context,
                AppRoutes.kAdminDashboardRoute,
              );
            } else {
              AppNavigation.push(context, AppRoutes.kAdminLoginRoute);
            }
          },
        ),
      );
      tiles.add(const SizedBox(height: 16));
      tiles.add(const _SectionHeader(label: 'Preferences'));
      tiles.add(
        BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            final isDarkMode = state.themeMode == ThemeMode.dark;
            return _DrawerTile(
              icon: isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              label: isDarkMode ? 'Light Mode' : 'Dark Mode',
              index: index++,
              onTap: () => context.read<ThemeCubit>().toggleTheme(),
            );
          },
        ),
      );
      tiles.add(const SizedBox(height: 16));
      tiles.add(const _SectionHeader(label: 'Attendance'));
      tiles.add(
        _DrawerTile(
          icon: Icons.fact_check_outlined,
          label: 'My Attendance',
          index: index++,
          onTap: () async {
            final email = FirebaseAuth.instance.currentUser?.email ?? '';

            final studentId = await context
                .read<EnrolledStudentsAdminCubit>()
                .getStudentIdByEmail(email);

            if (!context.mounted) return;

            context.pop();
            AppNavigation.push(
              context,
              AppRoutes.kStudentAttendanceRoute,
              queryParameters: {'studentId': studentId},
            );
          },
        ),
      );
      tiles.add(
        _DrawerTile(
          icon: Icons.qr_code_scanner_rounded,
          label: 'Scan QR',
          index: index++,
          onTap: () {
            Navigator.pop(context);
            AppNavigation.push(context, AppRoutes.kScanAttendanceRoute);
          },
        ),
      );
      tiles.add(const SizedBox(height: 16));
      tiles.add(const _SectionHeader(label: 'Legal'));
      tiles.add(
        _DrawerTile(
          icon: Icons.description_outlined,
          label: 'Terms & Conditions',
          index: index++,
          onTap: () {
            Navigator.pop(context);
            AppNavigation.push(context, AppRoutes.kTermsAndConditionsRoute);
          },
        ),
      );
      tiles.add(
        _DrawerTile(
          icon: Icons.privacy_tip_outlined,
          label: 'Privacy Policy',
          index: index++,
          onTap: () {
            Navigator.pop(context);
            // TODO: Navigate to Privacy Policy route
          },
        ),
      );
    }

    return Drawer(
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(AppConstants.defaultRadius * 2),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DrawerHeader(user: user, isAdminLoggedIn: isAdminLoggedIn),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding - 4,
                ),
                children: tiles,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.defaultPadding,
                8,
                AppConstants.defaultPadding,
                12,
              ),
              child: _LogoutTile(
                index: index,
                onTap: () async {
                  Navigator.pop(context);
                  await context.read<AuthCubit>().logout();
                  if (!context.mounted) return;
                  AppNavigation.goAndClearStack(context, AppRoutes.kLoginRoute);
                },
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

    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkBodyText : AppColors.lightBodyText;
    final secondaryTextColor = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    final displayName = user?.displayName ?? 'Guest User';
    final email = user?.email ?? 'Sign in to continue';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius * 1.5),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.darkNeutral
                      : AppColors.lightNeutral,
                  border: Border.all(
                    color: AppColors.primary,
                    width: AppConstants.defaultBorderWidth + 0.5,
                  ),
                ),
                child: ClipOval(
                  child: user?.photoURL != null
                      ? CachedNetworkImage(
                          imageUrl: user!.photoURL!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person_rounded,
                            color: isDark
                                ? AppColors.darkIcon
                                : AppColors.lightIcon,
                            size: 30,
                          ),
                        )
                      : Icon(
                          Icons.person_rounded,
                          size: 30,
                          color: isDark
                              ? AppColors.darkIcon
                              : AppColors.lightIcon,
                        ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isAdminLoggedIn
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.darkNeutral
                            : AppColors.lightNeutral),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAdminLoggedIn ? 'Admin' : 'Member',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isAdminLoggedIn
                        ? Colors.white
                        : (isDark
                              ? AppColors.darkBodyText
                              : AppColors.lightBodyText),
                  ),
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
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: secondaryTextColor,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.05, end: 0);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 6, top: 4),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: isDark
              ? AppColors.darkBodyTextSecondary
              : AppColors.lightBodyTextSecondary,
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.index,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
            leading: Icon(
              icon,
              size: AppConstants.defaultIconSize - 2,
              color: AppColors.secondary,
            ),
            title: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkBodyText
                    : AppColors.lightBodyText,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isDark
                  ? AppColors.darkBodyTextSecondary
                  : AppColors.lightBodyTextSecondary,
            ),
            onTap: onTap,
          ),
        )
        .animate()
        .fadeIn(delay: (60 * index).ms, duration: 250.ms)
        .slideX(begin: 0.04, end: 0);
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.index, required this.onTap});

  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius + 4),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius + 4),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Logout',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (60 * index).ms, duration: 250.ms)
        .slideY(begin: 0.1, end: 0);
  }
}
