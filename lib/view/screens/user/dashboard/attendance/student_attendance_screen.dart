import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/student_attendance/student_attendance_cubit.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

class StudentAttendanceScreen extends StatefulWidget {
  final String studentId;
  const StudentAttendanceScreen({super.key, required this.studentId});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  int _viewMode = 0; // 0 = monthly, 1 = weekly

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    context.read<StudentAttendanceCubit>().loadMonthly(
      widget.studentId,
      now.year,
      now.month,
    );
  }

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
      title: 'My Attendance',
      body: BlocBuilder<StudentAttendanceCubit, StudentAttendanceState>(
        builder: (context, state) {
          if (state.isLoading && state.dailyRecords.isEmpty) {
            return const _AttendanceShimmerLoading();
          }

          final presentDays = state.summary['present_days'] ?? 0;
          final totalDays = state.summary['total_days'] ?? 0;
          final percentage = ((state.summary['percentage'] ?? 0) as num)
              .toDouble();

          // Calculate leading padding offset for calendar alignment (Monday = 1)
          int leadingOffset = 0;
          if (_viewMode == 0 && state.dailyRecords.isNotEmpty) {
            final firstDateStr = state.dailyRecords.first['date']?.toString();
            final firstDate = DateTime.tryParse(firstDateStr ?? '');
            if (firstDate != null) {
              leadingOffset = firstDate.weekday - 1;
            }
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Enhanced Stat Card Header
              SliverToBoxAdapter(
                child:
                    Container(
                          margin: const EdgeInsets.all(
                            AppConstants.defaultPadding,
                          ),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.2 : 0.04,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _StatItem(
                                    label: 'Present',
                                    value: '$presentDays',
                                    color: AppColors.success,
                                  ),
                                  Container(
                                    height: 36,
                                    width: 1,
                                    color: borderColor,
                                  ),
                                  _StatItem(
                                    label: 'Total Days',
                                    value: '$totalDays',
                                    color: AppColors.info,
                                  ),
                                  Container(
                                    height: 36,
                                    width: 1,
                                    color: borderColor,
                                  ),
                                  _StatItem(
                                    label: 'Rate',
                                    value: '${percentage.toStringAsFixed(0)}%',
                                    color: AppColors.accent,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Progress Bar
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Overall Progress',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: secondaryTextColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.success,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: (percentage / 100).clamp(0.0, 1.0),
                                      minHeight: 8,
                                      backgroundColor: isDark
                                          ? AppColors.darkNeutral
                                          : AppColors.lightNeutral,
                                      valueColor: const AlwaysStoppedAnimation(
                                        AppColors.success,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.04, end: 0),
              ),

              // Segmented Toggle Control
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkNeutral
                          : AppColors.lightNeutral,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SegmentTab(
                            label: 'Monthly',
                            icon: Icons.calendar_month_rounded,
                            isSelected: _viewMode == 0,
                            onTap: () {
                              if (_viewMode == 0) return;
                              setState(() => _viewMode = 0);
                              context
                                  .read<StudentAttendanceCubit>()
                                  .loadMonthly(
                                    widget.studentId,
                                    state.year,
                                    state.month,
                                  );
                            },
                          ),
                        ),
                        Expanded(
                          child: _SegmentTab(
                            label: 'Weekly',
                            icon: Icons.view_week_rounded,
                            isSelected: _viewMode == 1,
                            onTap: () {
                              if (_viewMode == 1) return;
                              setState(() => _viewMode = 1);
                              final now = DateTime.now();
                              final weekStart = now.subtract(
                                Duration(days: now.weekday - 1),
                              );
                              context.read<StudentAttendanceCubit>().loadWeekly(
                                widget.studentId,
                                weekStart,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Month Navigator Header (Monthly Mode)
              if (_viewMode == 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: borderColor),
                            ),
                          ),
                          onPressed: () {
                            final cubit = context
                                .read<StudentAttendanceCubit>();
                            cubit.previousMonth();
                            cubit.loadMonthly(
                              widget.studentId,
                              cubit.state.year,
                              cubit.state.month,
                            );
                          },
                        ),
                        Text(
                          DateFormat(
                            'MMMM yyyy',
                          ).format(DateTime(state.year, state.month)),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: borderColor),
                            ),
                          ),
                          onPressed: () {
                            final cubit = context
                                .read<StudentAttendanceCubit>();
                            cubit.nextMonth();
                            cubit.loadMonthly(
                              widget.studentId,
                              cubit.state.year,
                              cubit.state.month,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Calendar Grid Header and Items
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    // Day labels (Row 1)
                    if (index < 7) {
                      final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                      return Center(
                        child: Text(
                          days[index],
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: secondaryTextColor,
                          ),
                        ),
                      );
                    }

                    final gridPosition = index - 7;

                    // Leading empty slots to align day 1 to correct weekday column
                    if (gridPosition < leadingOffset) {
                      return const SizedBox.shrink();
                    }

                    final dayIndex = gridPosition - leadingOffset;
                    if (dayIndex >= state.dailyRecords.length) {
                      return const SizedBox.shrink();
                    }

                    final record = state.dailyRecords[dayIndex];
                    final date =
                        DateTime.tryParse(record['date']?.toString() ?? '') ??
                        DateTime.now();
                    final isPresent = record['is_present'] == true;
                    final now = DateTime.now();
                    final isToday =
                        now.year == date.year &&
                        now.month == date.month &&
                        now.day == date.day;

                    return Container(
                      decoration: BoxDecoration(
                        color: isPresent
                            ? AppColors.success.withValues(alpha: 0.15)
                            : isToday
                            ? AppColors.accent.withValues(alpha: 0.12)
                            : cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isToday
                              ? AppColors.accent
                              : isPresent
                              ? AppColors.success.withValues(alpha: 0.3)
                              : borderColor,
                          width: isToday ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isPresent
                                  ? AppColors.success
                                  : isToday
                                  ? AppColors.accent
                                  : null,
                            ),
                          ),
                          if (isPresent) ...[
                            const SizedBox(height: 2),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }, childCount: 7 + leadingOffset + state.dailyRecords.length),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkBodyTextSecondary
                : AppColors.lightBodyTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.accent : AppColors.secondary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceShimmerLoading extends StatelessWidget {
  const _AttendanceShimmerLoading();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderColor = isDark
        ? AppColors.darkCard
        : AppColors.lightBorder.withValues(alpha: 0.4);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child:
          Column(
                children: [
                  // Stat Card Shimmer
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: placeholderColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Toggle Shimmer
                  Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: placeholderColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Month Nav Shimmer
                  Container(
                    height: 40,
                    width: 180,
                    decoration: BoxDecoration(
                      color: placeholderColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Grid Shimmer
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                    itemCount: 35,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: placeholderColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    },
                  ),
                ],
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: 1200.ms,
                color: isDark ? Colors.white10 : Colors.white60,
              ),
    );
  }
}
