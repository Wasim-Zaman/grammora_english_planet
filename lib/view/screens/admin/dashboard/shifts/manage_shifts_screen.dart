import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/shift_form/shift_form_cubit.dart';
import 'package:gep/cubits/shift_form/shift_form_state.dart';
import 'package:gep/cubits/shifts/shifts_cubit.dart';
import 'package:gep/models/shift/shift.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/admin_list_tile.dart';
import 'package:gep/view/widgets/app_button.dart';
import 'package:gep/view/widgets/app_dialog.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/paginated_widget.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:gep/view/widgets/text_field_widget.dart';
import 'package:material_ui/material_ui.dart';

class ManageShiftsScreen extends StatefulWidget {
  const ManageShiftsScreen({super.key});

  @override
  State<ManageShiftsScreen> createState() => _ManageShiftsScreenState();
}

class _ManageShiftsScreenState extends State<ManageShiftsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<ShiftsCubit>().fetchPage(0);
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

    return BlocConsumer<ShiftsCubit, ShiftsState>(
      listener: (context, state) {
        if (state.error != null && !state.isLoading && !state.isRefreshing) {
          TopSnackbar.error(context, state.error!);
        }
      },
      builder: (context, state) {
        final items = state.items;
        final isLoading = state.isLoading && items.isEmpty;

        return AppScaffold(
          title: 'Manage Shifts',
          floatingActionButton: isLoading
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _showShiftSheet(context, null),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Shift'),
                ),
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
                          context.read<ShiftsCubit>().previousPage(),
                      onNext: () => context.read<ShiftsCubit>().nextPage(),
                      onPageSelected: (page) =>
                          context.read<ShiftsCubit>().goToPage(page),
                      onRefresh: () => context.read<ShiftsCubit>().refresh(),
                      currentPage: state.currentPage,
                      pageSize: 10,
                    ),
                  ),
                )
              : null,
          body: RefreshIndicator(
            onRefresh: () async => context.read<ShiftsCubit>().refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFieldWidget(
                    controller: _searchController,
                    labelText: 'Search shifts',
                    hintText: 'Search shifts…',
                    prefixIcon: Icons.search_rounded,
                    suffixIcon: state.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: textColorSecondary,
                            onPressed: () {
                              _searchController.clear();
                              context.read<ShiftsCubit>().clearSearch();
                            },
                          )
                        : null,
                    onChanged: (v) =>
                        context.read<ShiftsCubit>().setSearchQuery(v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 16, color: textColorSecondary),
                          const SizedBox(width: 6),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'AVAILABLE SHIFTS'
                                : 'SEARCH RESULTS',
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
                  _EmptyState(
                    onAdd: () => _showShiftSheet(context, null),
                    searchQuery: state.searchQuery,
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final shift = items[index];
                      return AdminListTile(
                        leadingIcon: Icons.schedule_rounded,
                        leadingBackgroundColor:
                            AppColors.accent.withValues(alpha: 0.12),
                        leadingIconColor: AppColors.accent,
                        title: shift.name,
                        subtitle: '${shift.timeRange} · ${shift.daysLabel}',
                        trailingActions: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => _showShiftSheet(context, shift),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: AppColors.error,
                            ),
                            onPressed: () => _confirmDelete(context, shift),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
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

  void _showShiftSheet(BuildContext context, Shift? shift) {
    final shiftsCubit = context.read<ShiftsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: shiftsCubit,
        child: _ShiftFormSheet(shift: shift),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Shift shift) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Delete Shift',
      message: 'Delete "${shift.name}"?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      context.read<ShiftsCubit>().deleteShift(shift.id);
    }
  }
}

class _ShiftFormSheet extends StatefulWidget {
  final Shift? shift;
  const _ShiftFormSheet({this.shift});

  @override
  State<_ShiftFormSheet> createState() => _ShiftFormSheetState();
}

class _ShiftFormSheetState extends State<_ShiftFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.shift?.name ?? '');
    _startController =
        TextEditingController(text: widget.shift?.startTime ?? '09:00');
    _endController =
        TextEditingController(text: widget.shift?.endTime ?? '11:00');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _save(BuildContext context, ShiftFormState formState) {
    final name = _nameController.text.trim();
    final start = _startController.text.trim();
    final end = _endController.text.trim();

    if (name.isEmpty ||
        start.isEmpty ||
        end.isEmpty ||
        formState.selectedDays.isEmpty) {
      TopSnackbar.error(context, 'Please fill all fields and select days');
      return;
    }

    final shift = Shift(
      id: widget.shift?.id ?? '',
      name: name,
      startTime: start,
      endTime: end,
      days: List.from(formState.selectedDays),
      createdAt: widget.shift?.createdAt ?? DateTime.now(),
    );

    if (widget.shift == null) {
      context.read<ShiftsCubit>().addShift(shift);
    } else {
      context.read<ShiftsCubit>().updateShift(widget.shift!.id, shift);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.darkScaffoldBackground
        : AppColors.lightScaffoldBackground;

    return BlocProvider(
      create: (_) => ShiftFormCubit(widget.shift?.days ?? []),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: AppScaffold(
            title: widget.shift == null ? 'Add Shift' : 'Edit Shift',
            body: BlocBuilder<ShiftFormCubit, ShiftFormState>(
              builder: (context, formState) {
                return ListView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  children: [
                    TextFieldWidget(
                      controller: _nameController,
                      labelText: 'Shift Name',
                      prefixIcon: Icons.title_rounded,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFieldWidget(
                            controller: _startController,
                            labelText: 'Start Time',
                            prefixIcon: Icons.access_time_rounded,
                            hintText: '09:00',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFieldWidget(
                            controller: _endController,
                            labelText: 'End Time',
                            prefixIcon: Icons.access_time_filled_rounded,
                            hintText: '11:00',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select Days',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _days.map((day) {
                        final selected = formState.selectedDays.contains(day);
                        return ChoiceChip(
                          label: Text(day),
                          selected: selected,
                          onSelected: (_) =>
                              context.read<ShiftFormCubit>().toggleDay(day),
                          selectedColor:
                              AppColors.accent.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: selected ? AppColors.accent : null,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label:
                          widget.shift == null ? 'Add Shift' : 'Save Changes',
                      onPressed: () => _save(context, formState),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  final String searchQuery;
  const _EmptyState({required this.onAdd, required this.searchQuery});

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
            Icon(Icons.schedule_outlined, size: 36, color: textColorSecondary),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty ? 'No Shifts Found' : 'No Matches',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              searchQuery.isEmpty
                  ? 'Tap + to add your first shift'
                  : 'No shifts match "$searchQuery"',
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColorSecondary,
              ),
            ),
            const SizedBox(height: 20),
            if (searchQuery.isEmpty)
              AppButton(
                label: 'Add Shift',
                icon: const Icon(Icons.add_rounded),
                expanded: false,
                onPressed: onAdd,
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
              'Failed to load shifts',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(error,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: textColorSecondary)),
          ],
        ),
      ),
    );
  }
}
