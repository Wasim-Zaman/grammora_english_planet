import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/user_courses/user_courses_cubit.dart';
import 'package:gep/cubits/user_courses/user_courses_state.dart';
import 'package:gep/models/course_outline.dart';
import 'package:gep/view/widgets/app_button.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/app_search_field.dart';
import 'package:gep/view/widgets/paginated_widget.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';

class CoursesOutlinesScreen extends StatefulWidget {
  const CoursesOutlinesScreen({super.key});

  @override
  State<CoursesOutlinesScreen> createState() => _CoursesOutlinesScreenState();
}

class _CoursesOutlinesScreenState extends State<CoursesOutlinesScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<UserCoursesCubit>().fetchPage(0);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColorSecondary = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return BlocBuilder<UserCoursesCubit, UserCoursesState>(
      builder: (context, state) {
        final courses = state.items;
        final isLoading = state.isLoading && courses.isEmpty;

        final totalWeeks = courses.fold<int>(
          0,
          (sum, c) => sum + c.weeks.length,
        );
        final totalTopics = courses.fold<int>(
          0,
          (sum, c) =>
              sum + c.weeks.fold<int>(0, (wSum, w) => wSum + w.topics.length),
        );
        final allExpanded =
            courses.isNotEmpty &&
            state.expandedCourseIds.length >= courses.length;

        return AppScaffold(
          title: 'Courses & Outlines',
          backgroundColor: theme.scaffoldBackgroundColor,
          safeAreaBottom: false,
          bottomNavigationBar: courses.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border(
                      top: BorderSide(color: borderColor, width: 1),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding,
                        vertical: 10,
                      ),
                      child: PaginatedWidget(
                        isLoading: state.isLoading || state.isRefreshing,
                        hasPrevious: state.currentPage > 0,
                        hasNext: state.hasMore,
                        onPrevious: () =>
                            context.read<UserCoursesCubit>().previousPage(),
                        onNext: () =>
                            context.read<UserCoursesCubit>().nextPage(),
                        onPageSelected: (page) =>
                            context.read<UserCoursesCubit>().goToPage(page),
                        onRefresh: () =>
                            context.read<UserCoursesCubit>().refresh(),
                        currentPage: state.currentPage,
                        pageSize: 10,
                      ),
                    ),
                  ),
                )
              : null,
          body: RefreshIndicator(
            onRefresh: () async => context.read<UserCoursesCubit>().refresh(),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Curriculum Overview Card (matching Dashboard _InsightCard)
                if (courses.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.defaultPadding,
                        12,
                        AppConstants.defaultPadding,
                        8,
                      ),
                      child: _CurriculumOverviewCard(
                        totalCourses: courses.length,
                        totalWeeks: totalWeeks,
                        totalTopics: totalTopics,
                        allExpanded: allExpanded,
                        onToggleExpandAll: () => context
                            .read<UserCoursesCubit>()
                            .toggleExpandAllCourses(),
                      ),
                    ),
                  ),

                // Search Input
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.defaultPadding,
                      6,
                      AppConstants.defaultPadding,
                      6,
                    ),
                    child: AppSearchField(
                      controller: _searchController,
                      query: state.searchQuery,
                      labelText: 'Search courses',
                      hintText: 'Search courses, subjects, or topics…',
                      onChanged: (v) =>
                          context.read<UserCoursesCubit>().setSearchQuery(v),
                      onClear: () =>
                          context.read<UserCoursesCubit>().clearSearch(),
                    ),
                  ),
                ),

                // Section Header (matching Dashboard _SectionHeader)
                if (!isLoading && courses.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      icon: Icons.school_rounded,
                      title: state.searchQuery.isEmpty
                          ? 'AVAILABLE COURSES'
                          : 'SEARCH RESULTS',
                      countBadge: '${courses.length}',
                    ),
                  ),

                // Loading State
                if (isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                      vertical: 12,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: PlaceholderWidgets.listPlaceholder(),
                    ),
                  )
                // Error State
                else if (state.error != null && courses.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load courses',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.error!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: textColorSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 140,
                            child: AppButton(
                              label: 'Retry',
                              onPressed: () =>
                                  context.read<UserCoursesCubit>().refresh(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                // Empty State
                else if (courses.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            AppLotties.courses,
                            width: 130,
                            height: 130,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.menu_book_rounded,
                              size: 48,
                              color: textColorSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'No courses found'
                                : 'No matches for "${state.searchQuery}"',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'Check back later for updated outlines'
                                : 'Try searching with another keyword',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: textColorSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                // Courses List
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.defaultPadding,
                      4,
                      AppConstants.defaultPadding,
                      24,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final course = courses[index];
                        final id = (course.id != null && course.id!.isNotEmpty)
                            ? course.id!
                            : course.title;
                        final isExpanded = state.expandedCourseIds.contains(id);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CourseCard(
                            course: course,
                            courseId: id,
                            index: index,
                            isExpanded: isExpanded,
                          ),
                        );
                      }, childCount: courses.length),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Overview card styled identically to Dashboard's _InsightCard
class _CurriculumOverviewCard extends StatelessWidget {
  final int totalCourses;
  final int totalWeeks;
  final int totalTopics;
  final bool allExpanded;
  final VoidCallback onToggleExpandAll;

  const _CurriculumOverviewCard({
    required this.totalCourses,
    required this.totalWeeks,
    required this.totalTopics,
    required this.allExpanded,
    required this.onToggleExpandAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRICULUM OVERVIEW',
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
                        '$totalCourses',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Active Syllabi',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onToggleExpandAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkNeutral
                        : AppColors.lightNeutral,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        allExpanded
                            ? Icons.unfold_less_rounded
                            : Icons.unfold_more_rounded,
                        size: 15,
                        color: isDark ? AppColors.darkIcon : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        allExpanded ? 'Collapse' : 'Expand all',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkBodyText
                              : AppColors.lightBodyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  label: 'Courses',
                  value: '$totalCourses',
                  progress: 1.0,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  label: 'Total Weeks',
                  value: '$totalWeeks',
                  progress: 1.0,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  label: 'Topics Covered',
                  value: '$totalTopics',
                  progress: 1.0,
                  color: AppColors.accent,
                  showBar: false,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

/// Stat chip identical to Dashboard _StatChip
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

/// Section header identical to Dashboard's _SectionHeader
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.countBadge,
  });

  final IconData icon;
  final String title;
  final String? countBadge;

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
          if (countBadge != null) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkNeutral : AppColors.lightNeutral,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                countBadge!,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkBodyText
                      : AppColors.lightBodyText,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Modern clean Course Card inspired by Dashboard _FeaturedActionCard
class _CourseCard extends StatelessWidget {
  final Course course;
  final String courseId;
  final int index;
  final bool isExpanded;

  const _CourseCard({
    required this.course,
    required this.courseId,
    required this.index,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColorSecondary = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    final totalTopics = course.weeks.fold<int>(
      0,
      (sum, w) => sum + w.topics.length,
    );

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () =>
            context.read<UserCoursesCubit>().toggleCourseExpansion(courseId),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkNeutral
                          : AppColors.lightNeutral,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      size: 20,
                      color: isDark ? AppColors.darkIcon : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${course.weeks.length} Weeks • $totalTopics Topics',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: textColorSecondary,
                          ),
                        ),
                      ],
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
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: isDark ? AppColors.darkIcon : AppColors.lightIcon,
                    ),
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 14),
                Divider(color: borderColor, height: 1),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: course.weeks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, weekIndex) {
                    final week = course.weeks[weekIndex];
                    return _WeekSection(
                      week: week,
                      weekIndex: weekIndex,
                      courseId: courseId,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (40 + index * 30).ms).slideY(begin: 0.04, end: 0);
  }
}

/// Week section rendered with clean, modern layout
class _WeekSection extends StatelessWidget {
  final Week week;
  final int weekIndex;
  final String courseId;

  const _WeekSection({
    required this.week,
    required this.weekIndex,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkNeutral.withValues(alpha: 0.45)
            : AppColors.lightNeutral.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.secondary : AppColors.primary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Week ${(weekIndex + 1).toString().padLeft(2, '0')}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.secondary : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  week.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (week.topics.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final topic in week.topics)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.secondary
                              : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        topic,
                        style: theme.textTheme.bodySmall?.copyWith(
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
        ],
      ),
    );
  }
}
