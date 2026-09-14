import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/attendance_admin/attendance_admin_cubit.dart';

import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/admin_list_tile.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/paginated_widget.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:material_ui/material_ui.dart';

class AdminAttendanceRecordsScreen extends StatefulWidget {
  const AdminAttendanceRecordsScreen({super.key});

  @override
  State<AdminAttendanceRecordsScreen> createState() =>
      _AdminAttendanceRecordsScreenState();
}

class _AdminAttendanceRecordsScreenState
    extends State<AdminAttendanceRecordsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AttendanceAdminCubit>().loadShifts();
    context.read<AttendanceAdminCubit>().fetchPage(0);
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

    return BlocConsumer<AttendanceAdminCubit, AttendanceAdminState>(
      listener: (context, state) {
        if (state.error != null && !state.isLoading && !state.isRefreshing) {
          TopSnackbar.error(context, state.error!);
        }
      },
      builder: (context, state) {
        final items = state.items;
        final isLoading = state.isLoading && items.isEmpty;

        return AppScaffold(
          title: 'Attendance Records',
          bottomNavigationBar: items.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border(top: BorderSide(color: borderColor)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: PaginatedWidget(
                      isLoading: state.isLoading || state.isRefreshing,
                      hasPrevious: state.currentPage > 0,
                      hasNext: state.hasMore,
                      onPrevious: () =>
                          context.read<AttendanceAdminCubit>().previousPage(),
                      onNext: () =>
                          context.read<AttendanceAdminCubit>().nextPage(),
                      onPageSelected: (page) =>
                          context.read<AttendanceAdminCubit>().goToPage(page),
                      onRefresh: () =>
                          context.read<AttendanceAdminCubit>().refresh(),
                      currentPage: state.currentPage,
                      pageSize: 15,
                    ),
                  ),
                )
              : null,
          body: RefreshIndicator(
            onRefresh: () async =>
                context.read<AttendanceAdminCubit>().refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                // Filters
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filters',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('All Shifts'),
                            selected: state.shiftFilter == null,
                            onSelected: (_) => context
                                .read<AttendanceAdminCubit>()
                                .clearFilters(),
                          ),
                          ...state.shifts.map((shift) {
                            final selected = state.shiftFilter == shift.id;
                            return FilterChip(
                              label: Text(shift.name),
                              selected: selected,
                              onSelected: (_) => context
                                  .read<AttendanceAdminCubit>()
                                  .setShiftFilter(shift.id),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.calendar_today_rounded,
                            color: theme.colorScheme.primary),
                        title: const Text('Date Filter'),
                        subtitle: Text(
                          state.dateFilter?.toString().split(' ').first ??
                              'All Dates',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (state.dateFilter != null)
                              IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () => context
                                    .read<AttendanceAdminCubit>()
                                    .clearFilters(),
                              ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: state.dateFilter ?? DateTime.now(),
                            firstDate: DateTime(DateTime.now().year),
                            lastDate: DateTime(DateTime.now().year + 5, 12, 31),
                          );
                          if (picked != null && context.mounted) {
                            context
                                .read<AttendanceAdminCubit>()
                                .setDateFilter(picked);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Header
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.fact_check_rounded,
                              size: 16, color: textColorSecondary),
                          const SizedBox(width: 6),
                          Text(
                            'RECORDS',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: textColorSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (!isLoading && items.isNotEmpty)
                        Badge(
                          label: Text('${items.length}'),
                          backgroundColor: isDark
                              ? AppColors.darkNeutral
                              : AppColors.lightNeutral,
                          textColor: isDark
                              ? AppColors.darkBodyText
                              : AppColors.lightBodyText,
                        ),
                    ],
                  ),
                ),

                if (isLoading)
                  PlaceholderWidgets.listPlaceholder()
                else if (state.error != null && items.isEmpty)
                  _ErrorState(error: state.error!)
                else if (items.isEmpty)
                  _EmptyState()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final record = items[index];
                      final shiftName =
                          (record['shifts'] as Map<String, dynamic>?)?['name'] ??
                              'Unknown';
                      final studentName =
                          (record['enrolled_students']
                                  as Map<String, dynamic>?)?['name'] ??
                              'Unknown';
                      final date = record['date']?.toString() ?? '';
                      final markedBy =
                          record['marked_by']?.toString() ?? 'qr_scan';

                      return AdminListTile(
                        leadingIcon: Icons.check_circle_rounded,
                        leadingBackgroundColor:
                            AppColors.success.withValues(alpha: 0.12),
                        leadingIconColor: AppColors.success,
                        title: studentName,
                        subtitle: '$shiftName · $date',
                        trailingActions: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkNeutral
                                  : AppColors.lightNeutral,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              markedBy == 'qr_scan' ? 'QR' : 'Manual',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColorSecondary = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.fact_check_outlined,
                size: 36, color: textColorSecondary),
            const SizedBox(height: 16),
            Text(
              'No Records Found',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Attendance records will appear here',
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColorSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColorSecondary = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Failed to load records',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(error,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: textColorSecondary)),
          ],
        ),
      ),
    );
  }
}
