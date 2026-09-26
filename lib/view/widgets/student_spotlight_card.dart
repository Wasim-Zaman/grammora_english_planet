import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/constants.dart';
import '../../cubits/user_student_spotlight/spotlight_carousel_cubit.dart';
import '../../cubits/user_student_spotlight/user_student_spotlight_cubit.dart';
import '../../cubits/user_student_spotlight/user_student_spotlight_state.dart';
import '../../models/student_spotlight.dart';
import '../../router/app_navigation.dart';
import '../../router/app_routes.dart';
import 'cached_image_widget.dart';

class StudentSpotlightDashboardCard extends StatelessWidget {
  const StudentSpotlightDashboardCard({super.key});

  // Fixed compact card height and avatar sizing
  static const double cardHeight = 88;
  static const double avatarSize = 56;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SpotlightCarouselCubit(),
      child: const _StudentSpotlightCardView(),
    );
  }
}

class _StudentSpotlightCardView extends StatelessWidget {
  const _StudentSpotlightCardView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final secondaryTextColor = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return BlocBuilder<UserStudentSpotlightCubit, UserStudentSpotlightState>(
      builder: (context, state) {
        if (state.isLoading && state.spotlights.isEmpty) {
          return const SizedBox.shrink();
        }

        final featured = state.featuredSpotlights;

        if (featured.isEmpty) {
          return const SizedBox.shrink();
        }

        if (featured.length == 1) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            child: _buildFeaturedItem(
              context,
              featured.first,
              theme,
              isDark,
              cardColor,
              borderColor,
              secondaryTextColor,
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CarouselSlider.builder(
              itemCount: featured.length,
              options: CarouselOptions(
                height: StudentSpotlightDashboardCard.cardHeight,
                viewportFraction: 0.92,
                enlargeCenterPage: false,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                onPageChanged: (index, _) {
                  context.read<SpotlightCarouselCubit>().setIndex(index);
                },
              ),
              itemBuilder: (context, index, _) {
                return _buildFeaturedItem(
                  context,
                  featured[index],
                  theme,
                  isDark,
                  cardColor,
                  borderColor,
                  secondaryTextColor,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                );
              },
            ),
            if (featured.length > 1) ...[
              const SizedBox(height: 5),
              BlocBuilder<SpotlightCarouselCubit, int>(
                builder: (context, currentIndex) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(featured.length, (index) {
                      final isSelected = currentIndex == index;
                      final isYear = featured[index].awardTitle
                          .toLowerCase()
                          .contains('year');
                      final accent = isYear
                          ? (isDark ? AppColors.accent : AppColors.warning)
                          : AppColors.secondary;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        width: isSelected ? 14 : 4,
                        height: 3.5,
                        decoration: BoxDecoration(
                          color: isSelected ? accent : borderColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildFeaturedItem(
    BuildContext context,
    StudentSpotlightModel student,
    ThemeData theme,
    bool isDark,
    Color cardColor,
    Color borderColor,
    Color secondaryTextColor, {
    EdgeInsetsGeometry? margin,
  }) {
    final isYear = student.awardTitle.toLowerCase().contains('year');
    final accent = isYear
        ? (isDark ? AppColors.accent : AppColors.warning)
        : AppColors.secondary;

    // Subtitle string combining course/batch and quote preview
    final subtitleParts = <String>[
      if (student.courseOrBatch.isNotEmpty) student.courseOrBatch,
      if (student.quoteOrMessage.isNotEmpty) '"${student.quoteOrMessage}"',
    ];
    final subtitleText = subtitleParts.join('  •  ');

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () =>
            AppNavigation.push(context, AppRoutes.kStudentSpotlightRoute),
        child: Container(
          height: StudentSpotlightDashboardCard.cardHeight,
          margin: margin,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accent.withValues(alpha: isDark ? 0.35 : 0.25),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: isDark ? 0.12 : 0.05),
                cardColor,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.transparent
                    : accent.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular Photo with docked badge
              SizedBox(
                width: StudentSpotlightDashboardCard.avatarSize,
                height: StudentSpotlightDashboardCard.avatarSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: StudentSpotlightDashboardCard.avatarSize,
                      height: StudentSpotlightDashboardCard.avatarSize,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accent.withValues(alpha: 0.8),
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
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent,
                          border: Border.all(color: cardColor, width: 2),
                        ),
                        child: Icon(
                          isYear ? Iconsax.cup : Iconsax.award,
                          size: 10.5,
                          color: isDark
                              ? AppColors.primary
                              : AppColors.lightCard,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Details Column (Award badge + Student Name + Course/Quote)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top: Tag + Period
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(
                              alpha: isDark ? 0.20 : 0.12,
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
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (student.period.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '•  ${student.period}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: secondaryTextColor,
                                height: 1.1,
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
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                    ),

                    // Subtitle / Course / Quote
                    if (subtitleText.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: secondaryTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),

              // Subtle forward chevron
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}
