import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/theme/theme_cubit.dart';
import 'package:gep/router/app_navigation.dart';
import 'package:gep/router/app_routes.dart';
import 'package:gep/services/analytics/analytics_service.dart';
import 'package:gep/view/widgets/app_drawer.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/grid_item.dart';
import 'package:material_ui/material_ui.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, dynamic>> primaryActions = [
      {
        'title': 'Manage Notes',
        'subtitle': 'Browse subject-wise notes',
        'gradient': AppGradients.notes,
        'routeName': AppRoutes.kAdminNotesCategoriesRoute,
        'icon': AppFeatureIcons.notes,
      },
      {
        'title': 'Manage Courses',
        'subtitle': 'Explore course outlines',
        'gradient': AppGradients.courses,
        'routeName': AppRoutes.kManageCoursesRoute,
        'icon': AppFeatureIcons.courses,
      },
    ];

    final List<Map<String, dynamic>> managementServices = [
      {
        'title': 'Updates',
        'icon': AppFeatureIcons.updates,
        'gradient': AppGradients.updates,
        'routeName': AppRoutes.kUpdatesManagementRoute,
      },
      {
        'title': 'Admissions',
        'icon': AppFeatureIcons.admissions,
        'gradient': AppGradients.admissions,
        'routeName': AppRoutes.kAdminAdmissionsRoute,
      },
      {
        'title': 'About Me',
        'icon': AppFeatureIcons.aboutMe,
        'gradient': AppGradients.aboutMe,
        'routeName': AppRoutes.kManageAboutMeRoute,
      },
      {
        'title': 'Banners',
        'icon': AppFeatureIcons.banners,
        'gradient': AppGradients.students,
        'routeName': AppRoutes.kManageBannerRoute,
      },
      {
        'title': 'Enrollment',
        'icon': AppFeatureIcons.students,
        'gradient': AppGradients.terms,
        'routeName': AppRoutes.kEnrollStudentsManagementRoute,
      },
      {
        'title': 'Shifts',
        'icon': AppFeatureIcons.shift,
        'gradient': AppGradients.courses,
        'routeName': AppRoutes.kManageShiftsRoute,
      },
      {
        'title': 'Attendance QR',
        'icon': AppFeatureIcons.qrCode,
        'gradient': AppGradients.admissions,
        'routeName': AppRoutes.kQrAttendanceRoute,
      },
      {
        'title': 'Attendance',
        'icon': AppFeatureIcons.attendance,
        'gradient': AppGradients.notes,
        'routeName': AppRoutes.kAdminAttendanceRecordsRoute,
      },
      {
        'title': 'Spotlight',
        'icon': AppFeatureIcons.spotlight,
        'gradient': AppGradients.spotlight,
        'routeName': AppRoutes.kManageStudentSpotlightRoute,
      },
    ];

    return AppScaffold(
      drawer: const AppDrawer(isAdminLoggedIn: true, isAdminDashboard: true),
      safeAreaBottom: false,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Header Hero Banner Card
          SliverToBoxAdapter(child: _buildHeaderCard(context, theme, isDark)),

          // Primary Actions Header
          const SliverToBoxAdapter(
            child: _SectionHeader(
              icon: Icons.bolt_rounded,
              title: 'PRIMARY ACTIONS',
            ),
          ),

          // Primary Actions Cards
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  for (var i = 0; i < primaryActions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(
                      child: _AdminPrimaryCard(
                        action: primaryActions[i],
                        index: i,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Management Services Header
          const SliverToBoxAdapter(
            child: _SectionHeader(
              icon: Icons.grid_view_rounded,
              title: 'MANAGEMENT SERVICES',
            ),
          ),

          // Management Services Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = managementServices[index];
                return GridItem(
                      title: item['title'],
                      gradient: item['gradient'],
                      routeName: item['routeName'],
                      icon: item['icon'],
                    )
                    .animate()
                    .fadeIn(delay: (60 + index * 30).ms)
                    .slideY(begin: 0.08, end: 0);
              }, childCount: managementServices.length),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, ThemeData theme, bool isDark) {
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColorSecondary = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        12,
        AppConstants.defaultPadding,
        8,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Builder(
                builder: (scaffoldContext) => Material(
                  color: isDark
                      ? AppColors.darkNeutral
                      : AppColors.lightNeutral,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Scaffold.of(scaffoldContext).openDrawer(),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.widgets_rounded,
                        color: isDark
                            ? AppColors.darkIcon
                            : AppColors.lightIcon,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME BACK / ADMIN',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: textColorSecondary,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sani',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, state) {
                  final isLight = state.themeMode == ThemeMode.light;
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkNeutral
                          : AppColors.lightNeutral,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isLight
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        size: 18,
                      ),
                      onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 20,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkNeutral : AppColors.lightNeutral,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.campaign_rounded,
                  size: 16,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Welcome to the Admin Dashboard! Control and manage system operations with ease.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkBodyText
                          : AppColors.lightBodyText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? AppColors.darkBodyTextSecondary : AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: isDark
                  ? AppColors.darkBodyTextSecondary
                  : AppColors.lightBodyTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminPrimaryCard extends StatelessWidget {
  const _AdminPrimaryCard({required this.action, required this.index});

  final Map<String, dynamic> action;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
          onTap: () async {
            await AnalyticsService().logButtonClick(action['title']);
            if (context.mounted) {
              AppNavigation.push(context, action['routeName']);
            }
          },
          child: Container(
            height: 175,
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkNeutral
                                : AppColors.lightNeutral,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            action['icon'],
                            size: 18,
                            color: isDark
                                ? AppColors.darkIcon
                                : AppColors.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkNeutral
                                : AppColors.lightNeutral,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_outward_rounded,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: action['gradient'],
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.25 : 0.08,
                              ),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            action['icon'],
                            size: 26,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      action['title'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      action['subtitle'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkBodyTextSecondary
                            : AppColors.lightBodyTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (index * 60).ms)
        .slideX(begin: index.isEven ? -0.05 : 0.05, end: 0);
  }
}
