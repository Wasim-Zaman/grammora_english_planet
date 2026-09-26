import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/constants.dart';
import '../../../../../cubits/user_student_spotlight/user_student_spotlight_cubit.dart';
import '../../../../../cubits/user_student_spotlight/user_student_spotlight_state.dart';
import '../../../../../models/student_spotlight.dart';
import '../../../../widgets/app_scaffold.dart';
import '../../../../widgets/cached_image_widget.dart';
import '../../../../widgets/placeholder_widget.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

class StudentSpotlightScreen extends StatelessWidget {
  const StudentSpotlightScreen({super.key});

  static const List<String> _filters = [
    'All',
    'Student of the Month',
    'Student of the Year',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final secondaryTextColor = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return AppScaffold(
      title: 'Hall of Fame',
      body: BlocBuilder<UserStudentSpotlightCubit, UserStudentSpotlightState>(
        builder: (context, state) {
          if (state.isLoading && state.spotlights.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: PlaceholderWidgets.listPlaceholder(),
            );
          }

          final spotlights = state.filteredSpotlights;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<UserStudentSpotlightCubit>().initSubscription();
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Compact Motivational Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.defaultPadding,
                      10,
                      AppConstants.defaultPadding,
                      6,
                    ),
                    child: _buildMotivationalBanner(context, theme, isDark),
                  ),
                ),

                // Category Filter Pills
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                      vertical: 6,
                    ),
                    child: _buildFilterSelector(
                      context,
                      state,
                      isDark,
                      borderColor,
                    ),
                  ),
                ),

                // List of Star Students
                if (spotlights.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildEmptyState(
                      theme,
                      isDark,
                      state.selectedFilter,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                      vertical: 8,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final student = spotlights[index];
                        return _buildStudentCard(
                          context,
                          student,
                          theme,
                          isDark,
                          cardColor,
                          borderColor,
                          secondaryTextColor,
                          index,
                        );
                      }, childCount: spotlights.length),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMotivationalBanner(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppGradients.spotlight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.16),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.award, size: 11, color: AppColors.accent),
                      SizedBox(width: 4),
                      Text(
                        'HONOR ROLL',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Student Spotlight',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Honoring top learners inspiring us with consistency.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Iconsax.cup, size: 22, color: AppColors.accent),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildFilterSelector(
    BuildContext context,
    UserStudentSpotlightState state,
    bool isDark,
    Color borderColor,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = state.selectedFilter == filter;
          final isYear = filter.contains('Year');
          final activeColor = isYear ? AppColors.accent : AppColors.primary;
          final activeTextColor = isYear ? AppColors.primary : Colors.white;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                context.read<UserStudentSpotlightCubit>().setFilter(filter);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeColor
                      : (isDark ? AppColors.darkCard : AppColors.lightCard),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? activeColor : borderColor,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(
                        filter == 'All'
                            ? Iconsax.category
                            : (isYear ? Iconsax.cup : Iconsax.award),
                        size: 12,
                        color: activeTextColor,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      filter,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? activeTextColor
                            : (isDark
                                  ? AppColors.darkBodyTextSecondary
                                  : AppColors.lightBodyTextSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStudentCard(
    BuildContext context,
    StudentSpotlightModel student,
    ThemeData theme,
    bool isDark,
    Color cardColor,
    Color borderColor,
    Color secondaryTextColor,
    int index,
  ) {
    final isYear = student.awardTitle.toLowerCase().contains('year');
    final accent = isYear
        ? (isDark ? AppColors.accent : AppColors.warning)
        : AppColors.secondary;

    final hasQuote = student.quoteOrMessage.trim().isNotEmpty;
    final hasHighlight = student.achievementHighlights.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showStudentDetailsSheet(context, student, isDark),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isYear
                    ? accent.withValues(alpha: isDark ? 0.45 : 0.35)
                    : borderColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Avatar + Info + Share Action
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Reduced Frame View: Sleek 50px avatar with docked mini badge
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            padding: const EdgeInsets.all(1.8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: accent.withValues(alpha: 0.85),
                                width: 1.8,
                              ),
                            ),
                            child: ClipOval(
                              child: CachedImageWidget(
                                imageUrl: student.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: -1,
                            bottom: -1,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accent,
                                border: Border.all(
                                  color: cardColor,
                                  width: 1.8,
                                ),
                              ),
                              child: Icon(
                                isYear ? Iconsax.cup : Iconsax.award,
                                size: 9.5,
                                color: isDark
                                    ? AppColors.primary
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Middle info: Badges, Name, Course
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Award & Period Pills
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: accent.withValues(
                                    alpha: isDark ? 0.2 : 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isYear ? Iconsax.cup : Iconsax.award,
                                      size: 10,
                                      color: accent,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      student.awardTitle.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                        color: accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (student.period.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    student.period,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),

                          // Student Name
                          Text(
                            student.studentName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),

                          // Course / Batch
                          if (student.courseOrBatch.isNotEmpty) ...[
                            const SizedBox(height: 1.5),
                            Row(
                              children: [
                                Icon(
                                  AppFeatureIcons.courses,
                                  size: 12,
                                  color: secondaryTextColor,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    student.courseOrBatch,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: secondaryTextColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Compact Share Button
                    IconButton(
                      onPressed: () => _shareStudent(student),
                      icon: Icon(
                        Icons.share_outlined,
                        size: 17,
                        color: secondaryTextColor,
                      ),
                      tooltip: 'Share Achievement',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),

                // Bottom Snippet (Quote or Highlights) - ultra compact
                if (hasQuote || hasHighlight) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkNeutral.withValues(alpha: 0.35)
                          : AppColors.lightNeutral.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          hasQuote
                              ? Icons.format_quote_rounded
                              : Icons.star_rounded,
                          size: 13,
                          color: accent,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            hasQuote
                                ? '"${student.quoteOrMessage}"'
                                : student.achievementHighlights,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontStyle: hasQuote
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              color: isDark
                                  ? AppColors.darkBodyTextSecondary
                                  : AppColors.lightBodyTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: 180.ms,
      delay: ((index < 5 ? index : 5) * 30).ms,
    );
  }

  void _showStudentDetailsSheet(
    BuildContext context,
    StudentSpotlightModel student,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final isYear = student.awardTitle.toLowerCase().contains('year');
    final accent = isYear
        ? (isDark ? AppColors.accent : AppColors.warning)
        : AppColors.secondary;
    final secondaryTextColor = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),

              // Avatar
              Container(
                width: 74,
                height: 74,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent, width: 2.2),
                ),
                child: ClipOval(
                  child: CachedImageWidget(
                    imageUrl: student.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Name
              Text(
                student.studentName,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),

              // Award pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isYear ? Iconsax.cup : Iconsax.award,
                      size: 14,
                      color: accent,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${student.awardTitle} • ${student.period}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),

              if (student.courseOrBatch.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppFeatureIcons.courses,
                      size: 14,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      student.courseOrBatch,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              if (student.quoteOrMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkNeutral.withValues(alpha: 0.5)
                        : AppColors.lightNeutral,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder)
                              .withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.format_quote_rounded, size: 18, color: accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          student.quoteOrMessage,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (student.achievementHighlights.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded, size: 16, color: accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          student.achievementHighlights,
                          style: TextStyle(
                            fontSize: 12.5,
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

              const SizedBox(height: 20),

              // Share button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _shareStudent(student);
                  },
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text(
                    'Share Achievement',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

  Widget _buildEmptyState(ThemeData theme, bool isDark, String filter) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkNeutral : AppColors.lightNeutral,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Iconsax.cup, size: 26, color: AppColors.secondary),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              filter == 'All'
                  ? 'No star students announced yet'
                  : 'No $filter announced yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Stay dedicated, attend classes regularly, and participate actively to be the next featured star!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.35,
                fontSize: 12,
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

  void _shareStudent(StudentSpotlightModel student) {
    final text =
        '🌟 Congratulations to ${student.studentName}!\n'
        'Honored as ${student.awardTitle} (${student.period}) at Gramora English Planet.\n'
        '${student.quoteOrMessage.isNotEmpty ? '"${student.quoteOrMessage}"\n' : ''}'
        'Keep shining and inspiring excellence! 🏆';
    SharePlus.instance.share(ShareParams(text: text));
  }
}
