import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';
import 'package:upgrader/upgrader.dart';

import '../../../../core/constants/constants.dart';
import '../../../../cubits/admin/admin_cubit.dart';
import '../../../../cubits/auth/auth_cubit.dart';
import '../../../../cubits/banner/banner_cubit.dart';
import '../../../../cubits/theme/theme_cubit.dart';
import '../../../../models/enrolled_students.dart';
import '../../../../router/app_navigation.dart';
import '../../../../router/app_routes.dart';
import '../../../../services/analytics/analytics_service.dart';
import '../../../../services/auth/auth_service.dart';
import '../../../widgets/announcement_strip.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/banner_slider.dart';
import '../../../widgets/cached_image_widget.dart';

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
      AppLotties.notes,
      AppRoutes.kNotesCategoriesRoute,
      AppGradients.notes,
      subtitle: 'Browse subject-wise notes',
      icon: Icons.menu_book_rounded,
    ),
    _Service(
      'Courses',
      AppLotties.courses,
      AppRoutes.kCoursesOutlinesRoute,
      AppGradients.courses,
      subtitle: 'Explore course outlines',
      icon: Icons.school_rounded,
    ),
    _Service(
      'Updates',
      AppLotties.updates,
      AppRoutes.kUpdatesRoute,
      AppGradients.updates,
      icon: Icons.campaign_rounded,
    ),
    _Service(
      'Admissions',
      AppLotties.admissions,
      AppRoutes.kAdmissionsRoute,
      AppGradients.admissions,
      icon: Icons.badge_rounded,
    ),
    _Service(
      'Students',
      AppLotties.students,
      AppRoutes.kEnrolledStudentsRoute,
      AppGradients.students,
      icon: Icons.groups_rounded,
    ),
    _Service(
      'About',
      AppLotties.aboutMe,
      AppRoutes.kAboutMeRoute,
      AppGradients.aboutMe,
      icon: Icons.info_rounded,
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

        return UpgradeAlert(
          upgrader: Upgrader(
            durationUntilAlertAgain: const Duration(days: 1),
            debugDisplayAlways: true,
            minAppVersion: '2.0.0',
          ),
          child: AppScaffold(
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
                        4,
                        AppConstants.defaultPadding,
                        8,
                      ),
                      child: _AdminAccessCard(),
                    ),
                  ),

                // Banner Slider
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: BlocProvider.value(
                      value: _bannerCubit,
                      child: const BannerSlider(),
                    ).animate().fadeIn(duration: 350.ms),
                  ),
                ),

                // Announcement Strip
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 2, bottom: 8),
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
                          if (i > 0) const SizedBox(width: 12),
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
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 100,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.0,
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
                    trailing: GestureDetector(
                      onTap: () => AppNavigation.push(
                        context,
                        AppRoutes.kEnrolledStudentsRoute,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View All',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
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
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(User? user, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColorSecondary = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    final firstName =
        (user?.displayName?.split(' ').first.trim().isNotEmpty ?? false)
        ? user!.displayName!.split(' ').first
        : 'Guest';

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        8,
        AppConstants.defaultPadding,
        4,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkNeutral : AppColors.lightNeutral,
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: Icon(
                Icons.widgets_rounded,
                color: isDark ? AppColors.darkIcon : AppColors.lightIcon,
                size: AppConstants.defaultIconSize - 4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting().toUpperCase()} / USER',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColorSecondary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  firstName,
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
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: AppConstants.defaultBorderWidth + 1,
                ),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: isDark
                    ? AppColors.darkNeutral
                    : AppColors.lightNeutral,
                child: ClipOval(
                  child: CachedImageWidget(
                    imageUrl: user?.photoURL ?? '',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
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

    return GestureDetector(
      onTap: () => AppNavigation.pushReplacement(
        context,
        AppRoutes.kAdminDashboardRoute,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            // Admin Icon Container
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.6,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              child: Icon(
                Icons.admin_panel_settings_outlined,
                color: primaryTextColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Admin Panel',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Manage students, shifts & attendance',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Compact Action Arrow
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 13,
                color: secondaryTextColor,
              ),
            ),
          ],
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
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkNeutral : AppColors.lightNeutral,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Icon(icon, size: 18),
          ),
        ),
      ),
    );
  }
}

class _Service {
  const _Service(
    this.title,
    this.lottie,
    this.route,
    this.gradient, {
    this.subtitle,
    required this.icon,
  });

  final String title;
  final String lottie;
  final String route;
  final Gradient gradient;
  final String? subtitle;
  final IconData icon;
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
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
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
          if (trailing != null) ...[const Spacer(), trailing!],
        ],
      ),
    );
  }
}

class _FeaturedActionCard extends StatelessWidget {
  const _FeaturedActionCard({required this.service, required this.index});

  final _Service service;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
          onTap: () async {
            await AnalyticsService().logButtonClick(service.title);
            if (context.mounted) AppNavigation.push(context, service.route);
          },
          child: Container(
            height: 132,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Opacity(
                    opacity: 0.25,
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: Lottie.asset(service.lottie, fit: BoxFit.contain),
                    ),
                  ),
                ),
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
                            service.icon,
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
                    Text(
                      service.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.subtitle ?? 'Open ${service.title}',
                      maxLines: 2,
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
        .fadeIn(delay: (index * 80).ms)
        .slideX(begin: index.isEven ? -0.06 : 0.06, end: 0);
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service, required this.index});

  final _Service service;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        await AnalyticsService().logButtonClick(service.title);
        if (context.mounted) AppNavigation.push(context, service.route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Lottie.asset(service.lottie, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              service.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (80 + index * 40).ms).slideY(begin: 0.1, end: 0);
  }
}

enum _EnrollmentTimeRange { rolling6Months, thisYear }

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

class _InsightCard extends StatefulWidget {
  const _InsightCard();

  @override
  State<_InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<_InsightCard> {
  _EnrollmentTimeRange _timeRange = _EnrollmentTimeRange.rolling6Months;
  late final Stream<List<EnrolledStudent>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = context.read<AdminCubit>().getEnrolledStudentsStream();
  }

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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: StreamBuilder<List<EnrolledStudent>>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingSkeleton(isDark);
            }

            if (snapshot.hasError) {
              return SizedBox(
                height: 160,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Unable to load enrollment data.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkBodyTextSecondary
                              : AppColors.lightBodyTextSecondary,
                        ),
                      ),
                    ],
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

            // Generate slots for selected time range
            final List<_MonthEnrollmentSlot> slots = [];
            if (_timeRange == _EnrollmentTimeRange.rolling6Months) {
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
            final peakSlot = slots.reduce((a, b) => a.count >= b.count ? a : b);
            final maxY = maxCountInWindow <= 0
                ? 5.0
                : (maxCountInWindow * 1.3).ceilToDouble();

            // Monthly Average in range
            final double avgPerMonth;
            if (_timeRange == _EnrollmentTimeRange.rolling6Months) {
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
              children: [
                // Top Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL ENROLLED',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkBodyTextSecondary
                                  : AppColors.lightBodyTextSecondary,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${students.length}',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 32,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: momColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: momColor.withValues(alpha: 0.25),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(momIcon, size: 13, color: momColor),
                                    const SizedBox(width: 3),
                                    Text(
                                      momText,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: momColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Active Student Database',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkBodyTextSecondary
                                  : AppColors.lightBodyTextSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Time Range Selector Pill
                    _buildRangeSelector(isDark),
                  ],
                ),
                const SizedBox(height: 18),

                // Interactive Chart Section
                SizedBox(
                  height: 140,
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        enabled: true,
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) =>
                              isDark ? AppColors.darkCard : AppColors.lightCard,
                          tooltipBorder: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                          tooltipBorderRadius: BorderRadius.circular(8),
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final index = spot.spotIndex;
                              if (index < 0 || index >= slots.length) {
                                return null;
                              }
                              final slot = slots[index];
                              return LineTooltipItem(
                                '${slot.fullLabel}\n',
                                TextStyle(
                                  color: isDark
                                      ? AppColors.darkBodyTextSecondary
                                      : AppColors.lightBodyTextSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                    text: '${spot.y.toInt()} enrolled',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              );
                            }).toList();
                          },
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxY <= 5
                            ? 1
                            : (maxY / 4).ceilToDouble(),
                        getDrawingHorizontalLine: (value) => FlLine(
                          color:
                              (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder)
                                  .withValues(alpha: 0.5),
                          strokeWidth: 1,
                          dashArray: const [4, 4],
                        ),
                      ),
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
                            reservedSize: 22,
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

                              return Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  slot.label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                        _timeRange ==
                                            _EnrollmentTimeRange.thisYear
                                        ? 9.0
                                        : 11.0,
                                    fontWeight: isCurrentMonth
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: isCurrentMonth
                                        ? accentColor
                                        : (isDark
                                              ? AppColors.darkBodyTextSecondary
                                              : AppColors
                                                    .lightBodyTextSecondary),
                                  ),
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
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              final isCurrent =
                                  index < slots.length &&
                                  slots[index].year == currentYear &&
                                  slots[index].month == currentMonth;
                              return FlDotCirclePainter(
                                radius: isCurrent ? 4.5 : 3,
                                color: isCurrent
                                    ? accentColor
                                    : (isDark
                                          ? AppColors.darkCard
                                          : AppColors.lightCard),
                                strokeWidth: 2,
                                strokeColor: accentColor,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                accentColor.withValues(alpha: 0.28),
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
                const SizedBox(height: 18),

                // KPI Metrics 2x2 Grid for optimal readability & no overflow
                Row(
                  children: [
                    Expanded(
                      child: _StatChip(
                        icon: Icons.calendar_today_rounded,
                        label: 'This Month',
                        value: '$thisMonthCount',
                        subtitle: DateFormat('MMMM').format(now),
                        progress: maxCountInWindow == 0
                            ? 0
                            : (thisMonthCount / maxCountInWindow).clamp(
                                0.0,
                                1.0,
                              ),
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatChip(
                        icon: Icons.event_available_rounded,
                        label: 'This Year ($currentYear)',
                        value: '$thisYearCount',
                        subtitle: students.isEmpty
                            ? '0%'
                            : '${((thisYearCount / students.length) * 100).toStringAsFixed(0)}% of total',
                        progress: students.isEmpty
                            ? 0
                            : (thisYearCount / students.length).clamp(0.0, 1.0),
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _StatChip(
                        icon: Icons.speed_rounded,
                        label: 'Avg / Month',
                        value: avgPerMonth.toStringAsFixed(1),
                        subtitle:
                            _timeRange == _EnrollmentTimeRange.rolling6Months
                            ? 'Past 6 months'
                            : 'YTD average',
                        progress: maxCountInWindow == 0
                            ? 0
                            : (avgPerMonth / maxCountInWindow).clamp(0.0, 1.0),
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatChip(
                        icon: Icons.emoji_events_rounded,
                        label: 'Peak Month',
                        value: peakSlot.count == 0 ? '—' : peakSlot.label,
                        subtitle: peakSlot.count > 0
                            ? '${peakSlot.count} students'
                            : 'No peaks yet',
                        progress: 1.0,
                        color: AppColors.accent,
                        showBar: false,
                        badge: peakSlot.count > 0 ? '${peakSlot.count}' : null,
                      ),
                    ),
                  ],
                ),

                // Secondary Demographic / Level highlights
                if (maleCount > 0 ||
                    femaleCount > 0 ||
                    topLevelName != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkNeutral.withValues(alpha: 0.4)
                          : AppColors.lightNeutral.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder.withValues(alpha: 0.4)
                            : AppColors.lightBorder.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.pie_chart_outline_rounded,
                          size: 16,
                          color: accentColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            [
                              if (maleCount > 0 || femaleCount > 0)
                                'Gender: ${(maleCount / (maleCount + femaleCount) * 100).round()}% M • ${(femaleCount / (maleCount + femaleCount) * 100).round()}% F',
                              if (topLevelName != null)
                                'Top: $topLevelName ($topLevelCount)',
                            ].join('   •   '),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRangeSelector(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkNeutral : AppColors.lightNeutral,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRangeTab(
            title: '6M',
            isSelected: _timeRange == _EnrollmentTimeRange.rolling6Months,
            isDark: isDark,
            onTap: () => setState(() {
              _timeRange = _EnrollmentTimeRange.rolling6Months;
            }),
          ),
          _buildRangeTab(
            title: 'Year',
            isSelected: _timeRange == _EnrollmentTimeRange.thisYear,
            isDark: isDark,
            onTap: () => setState(() {
              _timeRange = _EnrollmentTimeRange.thisYear;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeTab({
    required String title,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkCard : AppColors.lightCard)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? AppColors.secondary
                : (isDark
                      ? AppColors.darkBodyTextSecondary
                      : AppColors.lightBodyTextSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    return SizedBox(
      height: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 120,
                height: 28,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkNeutral
                      : AppColors.lightNeutral,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                width: 70,
                height: 24,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkNeutral
                      : AppColors.lightNeutral,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkNeutral : AppColors.lightNeutral,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              2,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == 0 ? 8.0 : 0),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkNeutral
                          : AppColors.lightNeutral,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return SizedBox(
      height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insights_rounded,
            size: 40,
            color: isDark
                ? AppColors.darkBodyTextSecondary
                : AppColors.lightBodyTextSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'No enrollments yet',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Student enrollment trends and metrics will appear here',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
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

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
    this.icon,
    this.subtitle,
    this.showBar = true,
    this.badge,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;
  final IconData? icon;
  final String? subtitle;
  final bool showBar;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkNeutral : AppColors.lightNeutral,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.5)
              : AppColors.lightBorder.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark
                      ? AppColors.darkBodyTextSecondary
                      : AppColors.lightBodyTextSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (icon != null) Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.darkBodyTextSecondary.withValues(alpha: 0.8)
                    : AppColors.lightBodyTextSecondary.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (showBar) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 3.5,
                backgroundColor: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
