import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/user_student_spotlight/user_student_spotlight_cubit.dart';
import 'package:gep/cubits/user_student_spotlight/user_student_spotlight_state.dart';
import 'package:gep/models/student_spotlight.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/cached_image_widget.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
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
                // Top Motivational Header Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.defaultPadding,
                      12,
                      AppConstants.defaultPadding,
                      8,
                    ),
                    child: _buildMotivationalBanner(context, theme, isDark),
                  ),
                ),

                // Category Filter Chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                      vertical: 6,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _filters.map((filter) {
                          final isSelected = state.selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(filter),
                              selected: isSelected,
                              showCheckmark: false,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.darkBodyTextSecondary
                                        : AppColors.lightBodyTextSecondary),
                              ),
                              backgroundColor: isDark
                                  ? AppColors.darkNeutral
                                  : AppColors.lightNeutral,
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : borderColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (_) {
                                context
                                    .read<UserStudentSpotlightCubit>()
                                    .setFilter(filter);
                              },
                            ),
                          );
                        }).toList(),
                      ),
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
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
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
                        },
                        childCount: spotlights.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.spotlight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.award, size: 14, color: AppColors.accent),
                      SizedBox(width: 5),
                      Text(
                        'EXCELLENCE & DEDICATION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Student Spotlight',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Honoring top learners who inspire us every day with consistency and enthusiasm.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.cup,
              size: 34,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.05, end: 0);
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isYear
              ? AppColors.accent.withValues(alpha: 0.6)
              : AppColors.secondary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Ribbon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isYear
                  ? AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.1)
                  : AppColors.secondary.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        isYear ? Iconsax.cup : Iconsax.award,
                        size: 16,
                        color: isYear
                            ? (isDark ? AppColors.accent : AppColors.warning)
                            : AppColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          student.awardTitle.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                            color: isYear
                                ? (isDark ? AppColors.accent : AppColors.warning)
                                : AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkNeutral
                        : AppColors.lightNeutral,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    student.period,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile & Details Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Student Photo with double border
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isYear ? AppColors.accent : AppColors.secondary,
                          width: 2.5,
                        ),
                      ),
                      child: ClipOval(
                        child: CachedImageWidget(
                          imageUrl: student.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.studentName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (student.courseOrBatch.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  AppFeatureIcons.courses,
                                  size: 14,
                                  color: secondaryTextColor,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    student.courseOrBatch,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: secondaryTextColor,
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
                  ],
                ),

                // Motivational Quote Bubble
                if (student.quoteOrMessage.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkNeutral.withValues(alpha: 0.5)
                          : AppColors.lightNeutral.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: borderColor.withValues(alpha: 0.7),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.format_quote_rounded,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            student.quoteOrMessage,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              height: 1.35,
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

                // Achievements highlights tag
                if (student.achievementHighlights.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          student.achievementHighlights,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Share / Inspire Button
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _shareStudent(student),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.share_outlined,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Share Achievement',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (index * 70).ms, duration: 300.ms)
        .slideY(begin: 0.05, end: 0);
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark, String filter) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkNeutral : AppColors.lightNeutral,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.cup,
                size: 44,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              filter == 'All'
                  ? 'No star students announced yet'
                  : 'No $filter announced yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stay dedicated, attend classes regularly, and participate actively to be the next featured star!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.4,
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
    final text = '🌟 Congratulations to ${student.studentName}!\n'
        'Honored as ${student.awardTitle} (${student.period}) at Gramora English Planet.\n'
        '${student.quoteOrMessage.isNotEmpty ? '"${student.quoteOrMessage}"\n' : ''}'
        'Keep shining and inspiring excellence! 🏆';
    Share.share(text);
  }
}
