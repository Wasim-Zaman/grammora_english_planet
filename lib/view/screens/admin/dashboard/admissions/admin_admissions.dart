import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/admin/admin_cubit.dart';
import 'package:gep/cubits/admission_form/admission_form_cubit.dart';
import 'package:gep/cubits/admission_form/admission_form_state.dart';
import 'package:gep/cubits/admissions/admissions_cubit.dart';
import 'package:gep/cubits/admissions/admissions_state.dart';
import 'package:gep/models/admission_announcement.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/admin_list_tile.dart';
import 'package:gep/view/widgets/app_button.dart';
import 'package:gep/view/widgets/app_dialog.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/paginated_widget.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:gep/view/widgets/text_field_widget.dart';
import 'package:material_ui/material_ui.dart';

class AdminAdmissionsScreen extends StatefulWidget {
  const AdminAdmissionsScreen({super.key});

  @override
  State<AdminAdmissionsScreen> createState() => _AdminAdmissionsScreenState();
}

class _AdminAdmissionsScreenState extends State<AdminAdmissionsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<AdmissionsCubit>().fetchPage(0);
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
    final adminCubit = context.read<AdminCubit>();

    return BlocConsumer<AdmissionsCubit, AdmissionsState>(
      listener: (context, state) {
        if (state.error != null && !state.isLoading && !state.isRefreshing) {
          TopSnackbar.error(context, state.error!);
        }
      },
      builder: (context, state) {
        final items = state.items;
        final isLoading = state.isLoading && items.isEmpty;

        return AppScaffold(
          title: 'Manage Admissions',
          floatingActionButton: isLoading
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _showAddEditSheet(context, adminCubit),
                  tooltip: 'Add Announcement',
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Announcement'),
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
                          context.read<AdmissionsCubit>().previousPage(),
                      onNext: () => context.read<AdmissionsCubit>().nextPage(),
                      onPageSelected: (page) =>
                          context.read<AdmissionsCubit>().goToPage(page),
                      onRefresh: () =>
                          context.read<AdmissionsCubit>().refresh(),
                      currentPage: state.currentPage,
                      pageSize: 10,
                    ),
                  ),
                )
              : null,
          body: RefreshIndicator(
            onRefresh: () async => context.read<AdmissionsCubit>().refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFieldWidget(
                    controller: _searchController,
                    labelText: 'Search announcements',
                    hintText: 'Search announcements…',
                    prefixIcon: Icons.search_rounded,
                    suffixIcon: state.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: textColorSecondary,
                            onPressed: () {
                              _searchController.clear();
                              context.read<AdmissionsCubit>().clearSearch();
                            },
                          )
                        : null,
                    onChanged: (v) =>
                        context.read<AdmissionsCubit>().setSearchQuery(v),
                  ),
                ),

                // Header Label & Badge
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.campaign_rounded,
                            size: 16,
                            color: textColorSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'AVAILABLE ANNOUNCEMENTS'
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

                // Body Content States
                if (isLoading)
                  PlaceholderWidgets.listPlaceholder()
                else if (state.error != null && items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load announcements',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.error!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: textColorSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.campaign_outlined,
                            size: 36,
                            color: textColorSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'No Announcements Found'
                                : 'No matches for "${state.searchQuery}"',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'Tap the + button below to add your first announcement'
                                : '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: textColorSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final announcement = items[index];
                      return AnnouncementCard(
                        announcement: announcement,
                        onEdit: () => _showAddEditSheet(
                          context,
                          adminCubit,
                          announcement: announcement,
                        ),
                        onDelete: () => _deleteAnnouncement(
                          adminCubit,
                          announcement,
                        ),
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

  void _showAddEditSheet(
    BuildContext context,
    AdminCubit adminCubit, {
    AdmissionAnnouncement? announcement,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditAnnouncementSheet(
        adminCubit: adminCubit,
        announcement: announcement,
      ),
    );
  }

  Future<void> _deleteAnnouncement(
    AdminCubit adminCubit,
    AdmissionAnnouncement announcement,
  ) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Delete Announcement',
      message:
          'Are you sure you want to delete "${announcement.title}"?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      adminCubit.deleteAdmissionAnnouncement(announcement.id);
    }
  }
}

class AnnouncementCard extends StatelessWidget {
  final AdmissionAnnouncement announcement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AdminListTile(
      leadingIcon: Icons.campaign_rounded,
      title: announcement.title,
      subtitle:
          '${_formatDate(announcement.startDate)} - ${_formatDate(announcement.endDate)}',
      trailingActions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          color: Theme.of(context).colorScheme.primary,
          onPressed: onEdit,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, size: 20),
          color: AppColors.error.withValues(alpha: 0.85),
          onPressed: onDelete,
        ),
      ],
      onTap: onEdit,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class AddEditAnnouncementSheet extends StatefulWidget {
  final AdminCubit adminCubit;
  final AdmissionAnnouncement? announcement;

  const AddEditAnnouncementSheet({
    super.key,
    required this.adminCubit,
    this.announcement,
  });

  @override
  State<AddEditAnnouncementSheet> createState() =>
      _AddEditAnnouncementSheetState();
}

class _AddEditAnnouncementSheetState
    extends State<AddEditAnnouncementSheet> {
  late TextEditingController _titleController;
  late TextEditingController _detailsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.announcement?.title);
    _detailsController = TextEditingController(
      text: widget.announcement?.details,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.darkScaffoldBackground
        : AppColors.lightScaffoldBackground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return BlocProvider(
      create: (_) => AdmissionFormCubit(
        initialStartDate: widget.announcement?.startDate,
        initialEndDate: widget.announcement?.endDate,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: AppScaffold(
            title: widget.announcement == null
                ? 'Add Announcement'
                : 'Edit Announcement',
            body: BlocBuilder<AdmissionFormCubit, AdmissionFormState>(
              builder: (context, formState) {
                return ListView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  children: [
                    TextFieldWidget(
                      controller: _titleController,
                      labelText: 'Title',
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    TextFieldWidget(
                      controller: _detailsController,
                      labelText: 'Details',
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Row(
                      children: [
                        Expanded(
                          child: _DatePickerTile(
                            label: 'Start Date',
                            date: formState.startDate,
                            cardColor: cardColor,
                            borderColor: borderColor,
                            onTap: () =>
                                _selectDate(context, isStartDate: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DatePickerTile(
                            label: 'End Date',
                            date: formState.endDate,
                            cardColor: cardColor,
                            borderColor: borderColor,
                            onTap: () =>
                                _selectDate(context, isStartDate: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.defaultPadding * 2),
                    AppButton(
                      label: widget.announcement == null
                          ? 'Add Announcement'
                          : 'Save Changes',
                      onPressed: () => _saveAnnouncement(context, formState),
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

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final cubit = context.read<AdmissionFormCubit>();
    final current = isStartDate ? cubit.state.startDate : cubit.state.endDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      if (isStartDate) {
        cubit.setStartDate(picked);
      } else {
        cubit.setEndDate(picked);
      }
    }
  }

  void _saveAnnouncement(BuildContext context, AdmissionFormState formState) {
    final announcement = AdmissionAnnouncement(
      id: widget.announcement?.id ?? '',
      title: _titleController.text,
      details: _detailsController.text,
      startDate: formState.startDate,
      endDate: formState.endDate,
    );

    if (widget.announcement == null) {
      widget.adminCubit.addAdmissionAnnouncement(announcement);
    } else {
      widget.adminCubit.updateAdmissionAnnouncement(announcement);
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final Color cardColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.label,
    required this.date,
    required this.cardColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IgnorePointer(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              leading: Icon(
                Icons.calendar_today_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              title: Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              subtitle: Text(
                '${date.day}/${date.month}/${date.year}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
