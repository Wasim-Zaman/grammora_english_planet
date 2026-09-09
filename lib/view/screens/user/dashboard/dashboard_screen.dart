import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
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
        final isAdminLoggedIn =
            authState is AuthSuccess ? authState.isAdmin : false;

        return UpgradeAlert(
          upgrader: Upgrader(
            durationUntilAlertAgain: const Duration(days: 1),
            debugDisplayAlways: true,
            minAppVersion: '1.0.0',
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
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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

            // Enrollment Insight
            const SliverToBoxAdapter(
              child: _SectionHeader(
                icon: Icons.analytics_rounded,
                title: 'ENROLLMENT INSIGHT',
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
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

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

class _InsightCard extends StatefulWidget {
  const _InsightCard();

  @override
  State<_InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<_InsightCard> {
  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
  ];

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
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<EnrolledStudent>>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 140,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }

            if (snapshot.hasError) {
              return const SizedBox(
                height: 140,
                child: Center(child: Text('Unable to load enrollment data.')),
              );
            }

            final students = snapshot.data ?? [];
            final now = DateTime.now();
            final counts = List.filled(6, 0);
            for (final student in students) {
              if (student.enrollmentDate.year == now.year &&
                  student.enrollmentDate.month <= 6) {
                counts[student.enrollmentDate.month - 1]++;
              }
            }
            final spots = List.generate(
              6,
              (i) => FlSpot(i.toDouble(), counts[i].toDouble()),
            );
            final maxCount = counts.reduce((a, b) => a > b ? a : b);
            final maxY = (maxCount + 1).toDouble();

            final thisMonthIndex = now.month - 1;
            final thisMonthCount = (thisMonthIndex >= 0 && thisMonthIndex < 6)
                ? counts[thisMonthIndex]
                : 0;
            final lastMonthIndex = thisMonthIndex - 1;
            final lastMonthCount = (lastMonthIndex >= 0 && lastMonthIndex < 6)
                ? counts[lastMonthIndex]
                : 0;
            final change = lastMonthCount == 0
                ? (thisMonthCount == 0 ? 0.0 : 100.0)
                : ((thisMonthCount - lastMonthCount) / lastMonthCount) * 100;
            final monthsElapsed = now.month.clamp(1, 6);
            final avgPerMonth =
                counts.take(monthsElapsed).fold<int>(0, (a, b) => a + b) /
                monthsElapsed;

            if (students.isEmpty) {
              return SizedBox(
                height: 140,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      size: 36,
                      color: isDark
                          ? AppColors.darkBodyTextSecondary
                          : AppColors.lightBodyTextSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No enrollments yet',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Student data will appear here',
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${students.length}',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 32,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (change >= 0
                                              ? AppColors.success
                                              : AppColors.error)
                                          .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      change >= 0
                                          ? Icons.arrow_upward_rounded
                                          : Icons.arrow_downward_rounded,
                                      size: 12,
                                      color: change >= 0
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${change.abs().toStringAsFixed(0)}%',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: change >= 0
                                                ? AppColors.success
                                                : AppColors.error,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      height: 50,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: 5,
                          minY: 0,
                          maxY: maxY,
                          lineTouchData: const LineTouchData(enabled: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: accentColor,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    accentColor.withValues(alpha: 0.35),
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
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatChip(
                        label: 'This Month',
                        value: '$thisMonthCount',
                        progress: maxCount == 0 ? 0 : thisMonthCount / maxCount,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatChip(
                        label: 'Avg / Month',
                        value: avgPerMonth.toStringAsFixed(1),
                        progress: maxCount == 0 ? 0 : avgPerMonth / maxCount,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatChip(
                        label: 'Peak Month',
                        value: maxCount == 0
                            ? '—'
                            : _months[counts.indexOf(maxCount)],
                        progress: 1,
                        color: AppColors.accent,
                        showBar: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(_months.length, (i) {
                    final isCurrent = i == thisMonthIndex;
                    return Expanded(
                      child: Text(
                        _months[i],
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isCurrent
                              ? (isDark
                                    ? AppColors.darkBodyText
                                    : AppColors.primary)
                              : (isDark
                                    ? AppColors.darkBodyTextSecondary
                                    : AppColors.lightBodyTextSecondary),
                          fontWeight: isCurrent
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
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
    this.showBar = true,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;
  final bool showBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkNeutral : AppColors.lightNeutral,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark
                  ? AppColors.darkBodyTextSecondary
                  : AppColors.lightBodyTextSecondary,
              fontSize: 10,
            ),
          ),
          if (showBar) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1).toDouble(),
                minHeight: 3,
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
