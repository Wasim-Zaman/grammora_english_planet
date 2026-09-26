import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/constants.dart';
import '../../../../cubits/admin/admin_cubit.dart';
import '../../../../cubits/auth/auth_cubit.dart';
import '../../../../cubits/banner/banner_cubit.dart';
import '../../../../cubits/dashboard/enrollment_range_cubit.dart';
import '../../../../cubits/theme/theme_cubit.dart';
import '../../../../cubits/user_student_spotlight/user_student_spotlight_cubit.dart';
import '../../../../cubits/user_student_spotlight/user_student_spotlight_state.dart';
import '../../../../models/enrolled_students.dart';
import '../../../../router/app_navigation.dart';
import '../../../../router/app_routes.dart';
import '../../../../services/analytics/analytics_service.dart';
import '../../../../services/auth/auth_service.dart';
import '../../../widgets/announcement_strip.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/banner_slider.dart';
import '../../../widgets/cached_image_widget.dart';
import '../../../widgets/student_spotlight_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AnalyticsService _analyticsService = AnalyticsService();
  late final BannerCubit _bannerCubit;

  static const List<_Service> _services = [
    _Service(
      'Notes',
      AppRoutes.kNotesCategoriesRoute,
      AppGradients.notes,
      subtitle: 'Browse subject-wise notes',
      icon: AppFeatureIcons.notes,
    ),
    _Service(
      'Courses',
      AppRoutes.kCoursesOutlinesRoute,
      AppGradients.courses,
      subtitle: 'Explore course outlines',
      icon: AppFeatureIcons.courses,
    ),
    _Service(
      'Updates',
      AppRoutes.kUpdatesRoute,
      AppGradients.updates,
      icon: AppFeatureIcons.updates,
    ),
    _Service(
      'Admissions',
      AppRoutes.kAdmissionsRoute,
      AppGradients.admissions,
      icon: AppFeatureIcons.admissions,
    ),
    _Service(
      'Students',
      AppRoutes.kEnrolledStudentsRoute,
      AppGradients.students,
      icon: AppFeatureIcons.students,
    ),
    _Service(
      'About',
      AppRoutes.kAboutMeRoute,
      AppGradients.aboutMe,
      icon: AppFeatureIcons.aboutMe,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bannerCubit = BannerCubit(
      bannersStream: context.read<AdminCubit>().getBannersStream(),
    );
    init();
  }

  @override
  void dispose() {
    _bannerCubit.close();
    super.dispose();
  }

  Future<void> init() async {
    await _analyticsService.logScreenView('Dashboard');
    if (!mounted) return;
    context.read<AuthCubit>().checkAdminStatus();
    _bannerCubit.fetchBanners();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthService().getCurrentUser();
    final featured = _services.take(2).toList();
    final rest = _services.skip(2).toList();

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final isAdminLoggedIn = authState is AuthSuccess
            ? authState.isAdmin
            : false;

        return AppScaffold(
          scaffoldKey: _scaffoldKey,
          drawer: AppDrawer(isAdminLoggedIn: isAdminLoggedIn),
          backgroundColor: theme.scaffoldBackgroundColor,
          safeAreaBottom: false,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(user, theme)),

              // Admin Panel Access (only for admins)
              if (isAdminLoggedIn)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.defaultPadding,
                      2,
                      AppConstants.defaultPadding,
                      6,
                    ),
                    child: _AdminAccessCard(),
                  ),
                ),

              // Student Spotlight Stories Reel (Top of the screen)
              BlocBuilder<UserStudentSpotlightCubit, UserStudentSpotlightState>(
                builder: (context, state) {
                  if (state.featuredSpotlights.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }

                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // _SectionHeader(
                          //   icon: AppFeatureIcons.spotlight,
                          //   title: 'SPOTLIGHT STORIES',
                          //   trailing: _SectionActionLink(
                          //     label: 'Hall of Fame',
                          //     onTap: () => AppNavigation.push(
                          //       context,
                          //       AppRoutes.kStudentSpotlightRoute,
                          //     ),
                          //   ),
                          // ),
                          const StudentSpotlightDashboardCard(),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Banner Slider
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: BlocProvider.value(
                    value: _bannerCubit,
                    child: const BannerSlider(),
                  ).animate().fadeIn(duration: 350.ms),
                ),
              ),

              // Announcement Strip
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 2, bottom: 6),
                  child: AnnouncementStrip(),
                ),
              ),

              // Quick Actions
              const SliverToBoxAdapter(
                child: _SectionHeader(
                  icon: Icons.bolt_rounded,
                  title: 'QUICK ACTIONS',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      for (var i = 0; i < featured.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(
                          child: _FeaturedActionCard(
                            service: featured[i],
                            index: i,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Explore — remaining services
              const SliverToBoxAdapter(
                child: _SectionHeader(
                  icon: Icons.grid_view_rounded,
                  title: 'EXPLORE',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 04,
                    crossAxisSpacing: 04,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _ServiceTile(service: rest[index], index: index),
                    childCount: rest.length,
                  ),
                ),
              ),

              // Enrollment Insights
              SliverToBoxAdapter(
                child: _SectionHeader(
                  icon: Icons.analytics_rounded,
                  title: 'ENROLLMENT INSIGHTS',
                  trailing: _SectionActionLink(
                    label: 'View All',
                    onTap: () => AppNavigation.push(
                      context,
                      AppRoutes.kEnrolledStudentsRoute,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: const _InsightCard()
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.05, end: 0),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // HERO HEADER — layered gradient card with soft glow orbs + glass menu
  // ---------------------------------------------------------------------
  Widget _buildHeader(User? user, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final neutralColor = isDark
        ? AppColors.darkNeutral
        : AppColors.lightNeutral;
    final iconColor = isDark ? AppColors.darkIcon : AppColors.primary;

    final firstName =
        (user?.displayName?.split(' ').first.trim().isNotEmpty ?? false)
        ? user!.displayName!.split(' ').first
        : 'Learner';

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        10,
        AppConstants.defaultPadding,
        6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor.withValues(alpha: 0.6)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.darkCard, AppColors.darkCard]
              : [AppColors.lightCard, AppColors.lightCard],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Decorative glow orbs for a modern, layered feel — purely
            // visual, clipped to the card so they never affect layout.
            Positioned(
              top: -36,
              right: -24,
              child: _GlowOrb(
                color: AppColors.secondary,
                size: 120,
                opacity: isDark ? 0.16 : 0.10,
              ),
            ),
            Positioned(
              bottom: -46,
              left: -30,
              child: _GlowOrb(
                color: AppColors.primary,
                size: 110,
                opacity: isDark ? 0.14 : 0.07,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Drawer menu button with ripple
                  Material(
                    color: neutralColor,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.widgets_rounded,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Greeting & User Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  AppColors.secondary,
                                  AppColors.secondary.withValues(alpha: 0.7),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                _greeting().toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 1.1,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          firstName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Theme toggle with animated icon switcher
                  BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, state) {
                      final isLight = state.themeMode == ThemeMode.light;
                      return _HeaderIconButton(
                        icon: isLight
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        isDark: isDark,
                        onTap: () => context.read<ThemeCubit>().toggleTheme(),
                      );
                    },
                  ),
                  const SizedBox(width: 8),

                  // User Avatar with gradient ring
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.secondary,
                              AppColors.secondary.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor: neutralColor,
                          child: ClipOval(
                            child: CachedImageWidget(
                              imageUrl: user?.photoURL ?? '',
                              width: 34,
                              height: 34,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

/// Soft blurred circle used purely for decorative depth in headers/cards.
class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
    required this.opacity,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminAccessCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = isDark
        ? AppColors.darkBodyText
        : AppColors.lightBodyText;
    final secondaryTextColor = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final neutralColor = isDark
        ? AppColors.darkNeutral
        : AppColors.lightNeutral;

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => AppNavigation.pushReplacement(
          context,
          AppRoutes.kAdminDashboardRoute,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              // Flat admin icon — no gradient tint, just a simple neutral chip.
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: neutralColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: AppColors.secondary,
                  size: 15,
                ),
              ),
              const SizedBox(width: 10),

              // Title + subtitle collapsed into a single line to save height.
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Admin Panel  ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: primaryTextColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                      TextSpan(
                        text: 'Students, shifts & attendance',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: secondaryTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),

              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.darkNeutral : AppColors.lightNeutral,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                RotationTransition(turns: animation, child: child),
            child: Icon(
              icon,
              key: ValueKey(icon),
              size: 19,
              color: isDark ? AppColors.darkIcon : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _Service {
  const _Service(
    this.title,
    this.route,
    this.gradient, {
    this.subtitle,
    required this.icon,
  });

  final String title;
  final String route;
  final Gradient gradient;
  final String? subtitle;
  final IconData icon;

  /// Best-effort primary color pulled from the gradient, used for tinted
  /// shadows/washes. Falls back to secondary brand color if unavailable.
  Color get accent {
    if (gradient is LinearGradient) {
      final colors = (gradient as LinearGradient).colors;
      if (colors.isNotEmpty) return colors.first;
    }
    return AppColors.secondary;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      // Exactly 16px to align perfectly with the card margins below
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        12,
        AppConstants.defaultPadding,
        7,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: isDark ? 0.22 : 0.14),
                  AppColors.secondary.withValues(alpha: isDark ? 0.08 : 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              icon,
              size: 14,
              color: isDark ? AppColors.secondary : AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              fontSize: 11.5,
              color: isDark
                  ? AppColors.darkBodyTextSecondary
                  : AppColors.lightBodyTextSecondary,
            ),
          ),
          if (trailing != null) ...[const Spacer(), trailing!],
        ],
      ),
    );
  }
}

class _SectionActionLink extends StatelessWidget {
  const _SectionActionLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.chevron_right_rounded,
                size: 15,
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// FEATURED CARD — gradient wash background + gradient-filled icon badge
// ---------------------------------------------------------------------
class _FeaturedActionCard extends StatelessWidget {
  const _FeaturedActionCard({required this.service, required this.index});

  final _Service service;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColorSecondary = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;
    final accent = service.accent;

    return Material(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () async {
              await AnalyticsService().logButtonClick(service.title);
              if (context.mounted) AppNavigation.push(context, service.route);
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 100),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColor),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: isDark ? 0.16 : 0.08),
                    cardBg,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.transparent
                        : accent.withValues(alpha: 0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -12,
                    child: Opacity(
                      opacity: isDark ? 0.10 : 0.07,
                      child: Icon(service.icon, size: 84, color: accent),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              gradient: service.gradient,
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              service.icon,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: cardBg,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: borderColor.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_outward_rounded,
                              size: 13,
                              color: textColorSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            service.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            service.subtitle ?? 'Open ${service.title}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: textColorSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (index * 80).ms)
        .slideX(begin: index.isEven ? -0.05 : 0.05, end: 0);
  }
}

// ---------------------------------------------------------------------
// EXPLORE TILE — gradient icon with matching soft colored shadow
// ---------------------------------------------------------------------
class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service, required this.index});

  final _Service service;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accent = service.accent;

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          await AnalyticsService().logButtonClick(service.title);
          if (context.mounted) AppNavigation.push(context, service.route);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.transparent
                    : accent.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: service.gradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: isDark ? 0.25 : 0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(service.icon, size: 22, color: Colors.white),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                service.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (80 + index * 40).ms).slideY(begin: 0.08, end: 0);
  }
}

class _MonthEnrollmentSlot {
  final String label;
  final String fullLabel;
  final int year;
  final int month;
  final int count;

  const _MonthEnrollmentSlot({
    required this.label,
    required this.fullLabel,
    required this.year,
    required this.month,
    required this.count,
  });
}

class _InsightCard extends StatelessWidget {
  const _InsightCard();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EnrollmentTimeRangeCubit(),
      child: const _InsightCardView(),
    );
  }
}

class _InsightCardView extends StatelessWidget {
  const _InsightCardView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = AppColors.secondary;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.transparent
                : AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: StreamBuilder<List<EnrolledStudent>>(
          stream: context.read<AdminCubit>().getEnrolledStudentsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingSkeleton(isDark);
            }

            if (snapshot.hasError) {
              return SizedBox(
                height: 90,
                child: Center(
                  child: Text(
                    'Unable to load enrollment data.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkBodyTextSecondary
                          : AppColors.lightBodyTextSecondary,
                    ),
                  ),
                ),
              );
            }

            final students = snapshot.data ?? [];
            if (students.isEmpty) {
              return _buildEmptyState(theme, isDark);
            }

            final now = DateTime.now();
            final currentYear = now.year;
            final currentMonth = now.month;

            // Accurate Month-over-Month (MoM) metrics
            final thisMonthCount = students
                .where(
                  (s) =>
                      s.enrollmentDate.year == currentYear &&
                      s.enrollmentDate.month == currentMonth,
                )
                .length;

            final lastMonthNum = currentMonth == 1 ? 12 : currentMonth - 1;
            final lastMonthYear = currentMonth == 1
                ? currentYear - 1
                : currentYear;
            final lastMonthCount = students
                .where(
                  (s) =>
                      s.enrollmentDate.year == lastMonthYear &&
                      s.enrollmentDate.month == lastMonthNum,
                )
                .length;

            final String momText;
            final IconData momIcon;
            final Color momColor;
            if (lastMonthCount == 0 && thisMonthCount == 0) {
              momText = '0%';
              momIcon = Icons.remove_rounded;
              momColor = isDark
                  ? AppColors.darkBodyTextSecondary
                  : AppColors.lightBodyTextSecondary;
            } else if (lastMonthCount == 0) {
              momText = '+$thisMonthCount new';
              momIcon = Icons.arrow_upward_rounded;
              momColor = AppColors.success;
            } else {
              final diff = thisMonthCount - lastMonthCount;
              final pct = (diff / lastMonthCount) * 100;
              if (pct > 0) {
                momText = '+${pct.toStringAsFixed(0)}%';
                momIcon = Icons.arrow_upward_rounded;
                momColor = AppColors.success;
              } else if (pct < 0) {
                momText = '${pct.toStringAsFixed(0)}%';
                momIcon = Icons.arrow_downward_rounded;
                momColor = AppColors.error;
              } else {
                momText = '0%';
                momIcon = Icons.remove_rounded;
                momColor = isDark
                    ? AppColors.darkBodyTextSecondary
                    : AppColors.lightBodyTextSecondary;
              }
            }

            // Current year to date total
            final thisYearCount = students
                .where((s) => s.enrollmentDate.year == currentYear)
                .length;

            return BlocBuilder<EnrollmentTimeRangeCubit, EnrollmentTimeRange>(
              builder: (context, timeRange) {
                // Generate slots for selected time range
                final List<_MonthEnrollmentSlot> slots = [];
                if (timeRange == EnrollmentTimeRange.rolling6Months) {
                  for (int i = 0; i < 6; i++) {
                    final offset = 5 - i;
                    var m = currentMonth - offset;
                    var y = currentYear;
                    while (m <= 0) {
                      m += 12;
                      y -= 1;
                    }
                    final dt = DateTime(y, m, 1);
                    final count = students
                        .where(
                          (s) =>
                              s.enrollmentDate.year == y &&
                              s.enrollmentDate.month == m,
                        )
                        .length;
                    slots.add(
                      _MonthEnrollmentSlot(
                        label: DateFormat.MMM().format(dt),
                        fullLabel: DateFormat('MMM yyyy').format(dt),
                        year: y,
                        month: m,
                        count: count,
                      ),
                    );
                  }
                } else {
                  for (int m = 1; m <= 12; m++) {
                    final dt = DateTime(currentYear, m, 1);
                    final count = students
                        .where(
                          (s) =>
                              s.enrollmentDate.year == currentYear &&
                              s.enrollmentDate.month == m,
                        )
                        .length;
                    slots.add(
                      _MonthEnrollmentSlot(
                        label: DateFormat.MMM().format(dt),
                        fullLabel: DateFormat('MMM yyyy').format(dt),
                        year: currentYear,
                        month: m,
                        count: count,
                      ),
                    );
                  }
                }

                final spots = List.generate(
                  slots.length,
                  (i) => FlSpot(i.toDouble(), slots[i].count.toDouble()),
                );

                final maxCountInWindow = slots
                    .map((s) => s.count)
                    .fold<int>(0, (a, b) => a > b ? a : b);
                final peakSlot = slots.reduce(
                  (a, b) => a.count >= b.count ? a : b,
                );
                final maxY = maxCountInWindow <= 0
                    ? 4.0
                    : (maxCountInWindow * 1.25).ceilToDouble();

                // Monthly Average in range
                final double avgPerMonth;
                if (timeRange == EnrollmentTimeRange.rolling6Months) {
                  final totalInWindow = slots.fold<int>(
                    0,
                    (sum, s) => sum + s.count,
                  );
                  avgPerMonth = totalInWindow / 6.0;
                } else {
                  final elapsedMonths = currentMonth.clamp(1, 12);
                  final totalElapsed = slots
                      .take(elapsedMonths)
                      .fold<int>(0, (sum, s) => sum + s.count);
                  avgPerMonth = totalElapsed / elapsedMonths;
                }

                // Demographics & Level Insights
                int maleCount = 0;
                int femaleCount = 0;
                final levelCounts = <String, int>{};
                for (final s in students) {
                  final g = s.gender.trim().toLowerCase();
                  if (g == 'male' || g == 'm') {
                    maleCount++;
                  } else if (g == 'female' || g == 'f') {
                    femaleCount++;
                  }
                  final lvl = s.level.trim();
                  if (lvl.isNotEmpty) {
                    levelCounts[lvl] = (levelCounts[lvl] ?? 0) + 1;
                  }
                }
                String? topLevelName;
                int topLevelCount = 0;
                levelCounts.forEach((lvl, count) {
                  if (count > topLevelCount) {
                    topLevelCount = count;
                    topLevelName = lvl;
                  }
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Compact Top Bar: Total + Trend Badge on left, 6M/Year switch on right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${students.length}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'STUDENTS',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkBodyTextSecondary
                                    : AppColors.lightBodyTextSecondary,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: momColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: momColor.withValues(alpha: 0.25),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(momIcon, size: 11, color: momColor),
                                  const SizedBox(width: 2),
                                  Text(
                                    momText,
                                    style: TextStyle(
                                      color: momColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        _buildCompactRangeSelector(context, timeRange, isDark),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Compact Sparkline (74px height)
                    SizedBox(
                      height: 74,
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(
                            enabled: true,
                            handleBuiltInTouches: true,
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (_) => isDark
                                  ? AppColors.darkCard
                                  : AppColors.lightCard,
                              tooltipBorder: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                              tooltipBorderRadius: BorderRadius.circular(8),
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              tooltipPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  final index = spot.spotIndex;
                                  if (index < 0 || index >= slots.length) {
                                    return null;
                                  }
                                  final slot = slots[index];
                                  return LineTooltipItem(
                                    '${slot.label}: ',
                                    TextStyle(
                                      color: isDark
                                          ? AppColors.darkBodyTextSecondary
                                          : AppColors.lightBodyTextSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '${spot.y.toInt()}',
                                        style: TextStyle(
                                          color: accentColor,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 18,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= slots.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final slot = slots[index];
                                  final isCurrentMonth =
                                      slot.year == currentYear &&
                                      slot.month == currentMonth;

                                  // For 12-month view on mobile, skip alternate months to prevent overlapping text, preserving current month
                                  if (timeRange ==
                                          EnrollmentTimeRange.thisYear &&
                                      index.isOdd &&
                                      !isCurrentMonth) {
                                    return const SizedBox.shrink();
                                  }

                                  return Text(
                                    slot.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: isCurrentMonth
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                      color: isCurrentMonth
                                          ? accentColor
                                          : (isDark
                                                ? AppColors
                                                      .darkBodyTextSecondary
                                                : AppColors
                                                      .lightBodyTextSecondary),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: (slots.length - 1).toDouble(),
                          minY: 0,
                          maxY: maxY,
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              curveSmoothness: 0.35,
                              color: accentColor,
                              barWidth: 2.5,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  final isCurrent =
                                      index < slots.length &&
                                      slots[index].year == currentYear &&
                                      slots[index].month == currentMonth;
                                  return FlDotCirclePainter(
                                    radius: isCurrent ? 3.5 : 2.2,
                                    color: isCurrent
                                        ? accentColor
                                        : (isDark
                                              ? AppColors.darkCard
                                              : AppColors.lightCard),
                                    strokeWidth: 1.5,
                                    strokeColor: accentColor,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    accentColor.withValues(alpha: 0.25),
                                    accentColor.withValues(alpha: 0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Sleek Single-Row Micro-KPI Strip (Takes only ~42px)
                    Row(
                      children: [
                        Expanded(
                          child: _CompactStatTile(
                            label: 'This Mo',
                            value: '$thisMonthCount',
                            color: accentColor,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _CompactStatTile(
                            label: 'Year $currentYear',
                            value: '$thisYearCount',
                            color: AppColors.info,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _CompactStatTile(
                            label: 'Avg / Mo',
                            value: avgPerMonth.toStringAsFixed(1),
                            color: AppColors.warning,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _CompactStatTile(
                            label: 'Peak',
                            value: peakSlot.count == 0 ? '—' : peakSlot.label,
                            color: AppColors.accent,
                            isDark: isDark,
                            badge: peakSlot.count > 0
                                ? '${peakSlot.count}'
                                : null,
                          ),
                        ),
                      ],
                    ),

                    // Ultra-thin footnote for demographics (if available)
                    if (maleCount > 0 ||
                        femaleCount > 0 ||
                        topLevelName != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pie_chart_outline_rounded,
                            size: 12,
                            color: accentColor.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              [
                                if (maleCount > 0 || femaleCount > 0)
                                  '${(maleCount / (maleCount + femaleCount) * 100).round()}% M • ${(femaleCount / (maleCount + femaleCount) * 100).round()}% F',
                                if (topLevelName != null)
                                  'Top: $topLevelName ($topLevelCount)',
                              ].join('   |   '),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.darkBodyTextSecondary
                                    : AppColors.lightBodyTextSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompactRangeSelector(
    BuildContext context,
    EnrollmentTimeRange timeRange,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkNeutral : AppColors.lightNeutral,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactRangeTab(
            title: '6M',
            isSelected: timeRange == EnrollmentTimeRange.rolling6Months,
            isDark: isDark,
            onTap: () =>
                context.read<EnrollmentTimeRangeCubit>().selectRolling6Months(),
          ),
          _buildCompactRangeTab(
            title: 'Year',
            isSelected: timeRange == EnrollmentTimeRange.thisYear,
            isDark: isDark,
            onTap: () =>
                context.read<EnrollmentTimeRangeCubit>().selectThisYear(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactRangeTab({
    required String title,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkCard : AppColors.lightCard)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: isDark
                          ? Colors.transparent
                          : AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? AppColors.secondary
                  : (isDark
                        ? AppColors.darkBodyTextSecondary
                        : AppColors.lightBodyTextSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    return SizedBox(
      height: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 90,
                height: 20,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkNeutral
                      : AppColors.lightNeutral,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Container(
                width: 50,
                height: 20,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkNeutral
                      : AppColors.lightNeutral,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkNeutral : AppColors.lightNeutral,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insights_rounded,
            size: 24,
            color: isDark
                ? AppColors.darkBodyTextSecondary
                : AppColors.lightBodyTextSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            'No enrollments yet',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
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

class _CompactStatTile extends StatelessWidget {
  const _CompactStatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    this.badge,
  });

  final String label;
  final String value;
  final Color color;
  final bool isDark;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: isDark ? 0.16 : 0.10),
            isDark
                ? AppColors.darkNeutral.withValues(alpha: 0.45)
                : AppColors.lightNeutral,
          ],
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.30 : 0.22),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3.5,
                      vertical: 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              color: isDark
                  ? AppColors.darkBodyTextSecondary
                  : AppColors.lightBodyTextSecondary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
