import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../../cubits/update_form/update_form_cubit.dart';
import '../../../../../cubits/update_form/update_form_state.dart';
import '../../../../../cubits/updates_admin/updates_admin_cubit.dart';
import '../../../../../cubits/updates_admin/updates_admin_state.dart';
import '../../../../../models/updates.dart';
import '../../../../../utils/snackbars.dart';
import '../../../../widgets/admin_list_tile.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_dialog.dart';
import '../../../../widgets/app_scaffold.dart';
import '../../../../widgets/paginated_widget.dart';
import '../../../../widgets/placeholder_widget.dart';
import '../../../../widgets/text_field_widget.dart';

class UpdatesManagementScreen extends StatefulWidget {
  const UpdatesManagementScreen({super.key});

  @override
  State<UpdatesManagementScreen> createState() =>
      _UpdatesManagementScreenState();
}

class _UpdatesManagementScreenState extends State<UpdatesManagementScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<UpdatesAdminCubit>().fetchPage(0);
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

    return BlocConsumer<UpdatesAdminCubit, UpdatesAdminState>(
      listener: (context, state) {
        if (state.error != null && !state.isLoading && !state.isRefreshing) {
          TopSnackbar.error(context, state.error!);
        }
      },
      builder: (context, state) {
        final updates = state.items;
        final isLoading = state.isLoading && updates.isEmpty;

        return AppScaffold(
          title: 'Updates Management',
          floatingActionButton: isLoading
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _showUpdateSheet(context, null),
                  tooltip: 'Add Update',
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Update'),
                ),
          bottomNavigationBar: updates.isNotEmpty
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
                          context.read<UpdatesAdminCubit>().previousPage(),
                      onNext: () =>
                          context.read<UpdatesAdminCubit>().nextPage(),
                      onPageSelected: (page) =>
                          context.read<UpdatesAdminCubit>().goToPage(page),
                      onRefresh: () =>
                          context.read<UpdatesAdminCubit>().refresh(),
                      currentPage: state.currentPage,
                      pageSize: 10,
                    ),
                  ),
                )
              : null,
          body: RefreshIndicator(
            onRefresh: () async => context.read<UpdatesAdminCubit>().refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFieldWidget(
                    controller: _searchController,
                    labelText: 'Search updates',
                    hintText: 'Search updates…',
                    prefixIcon: Icons.search_rounded,
                    suffixIcon: state.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: textColorSecondary,
                            onPressed: () {
                              _searchController.clear();
                              context.read<UpdatesAdminCubit>().clearSearch();
                            },
                          )
                        : null,
                    onChanged: (v) =>
                        context.read<UpdatesAdminCubit>().setSearchQuery(v),
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
                            Icons.update_rounded,
                            size: 16,
                            color: textColorSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'AVAILABLE UPDATES'
                                : 'SEARCH RESULTS',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: textColorSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (!isLoading && updates.isNotEmpty)
                        Badge(
                          label: Text('${updates.length}'),
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
                else if (state.error != null && updates.isEmpty)
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
                            'Failed to load updates',
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
                else if (updates.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_rounded,
                            size: 36,
                            color: textColorSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'No Updates Found'
                                : 'No matches for "${state.searchQuery}"',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'Tap the + button below to add your first update'
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
                    itemCount: updates.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final update = updates[index];
                      final typeIcon = _typeIcon(update.type);
                      final typeLabel = _typeLabel(update.type);

                      return AdminListTile(
                        leadingIcon: typeIcon,
                        title: update.title,
                        subtitle: '${update.formattedDate} · $typeLabel',
                        trailingActions: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            color: theme.colorScheme.primary,
                            onPressed: () =>
                                _showUpdateSheet(context, update),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                            ),
                            color: AppColors.error.withValues(alpha: 0.85),
                            onPressed: () => _confirmDelete(update),
                          ),
                        ],
                        onTap: () => _showUpdateSheet(context, update),
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

  Future<void> _showUpdateSheet(BuildContext context, Updates? update) async {
    final updatesAdminCubit = context.read<UpdatesAdminCubit>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: updatesAdminCubit),
          BlocProvider(
            create: (_) => UpdateFormCubit(
              initialDate: update?.date,
              initialType: update?.type,
            ),
          ),
        ],
        child: FractionallySizedBox(
          heightFactor: 0.85,
          child: _UpdateSheet(update: update),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Updates update) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Delete Update',
      message: 'Are you sure you want to delete "${update.title}"?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      context.read<UpdatesAdminCubit>().deleteUpdate(update.id);
    }
  }
}

class _UpdateSheet extends StatefulWidget {
  final Updates? update;
  const _UpdateSheet({this.update});

  @override
  State<_UpdateSheet> createState() => _UpdateSheetState();
}

class _UpdateSheetState extends State<_UpdateSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.update?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.update?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        child: AppScaffold(
          title: widget.update == null ? 'Add New Update' : 'Edit Update',
          body: BlocBuilder<UpdateFormCubit, UpdateFormState>(
            builder: (context, formState) {
              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(
                    AppConstants.defaultPadding,
                  ),
                  children: [
                    TextFieldWidget(
                      controller: _titleController,
                      labelText: 'Title',
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a title' : null,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    TextFieldWidget(
                      controller: _descriptionController,
                      labelText: 'Description',
                      validator: (value) => value!.isEmpty
                          ? 'Please enter a description'
                          : null,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: Icon(
                          Icons.calendar_today_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text('Date'),
                        subtitle: Text(
                          formState.selectedDate.toString().split(' ')[0],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: formState.selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null &&
                              picked != formState.selectedDate) {
                            if (context.mounted) {
                              context.read<UpdateFormCubit>().setDate(picked);
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    DropdownButtonFormField<UpdateType>(
                      key: ValueKey(formState.selectedType),
                      initialValue: formState.selectedType,
                      decoration: InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        filled: true,
                        fillColor: cardColor,
                      ),
                      items: UpdateType.values.map((UpdateType type) {
                        return DropdownMenuItem<UpdateType>(
                          value: type,
                          child: Row(
                            children: [
                              Icon(
                                _typeIcon(type),
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(_typeLabel(type)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (UpdateType? newValue) {
                        if (newValue != null) {
                          context.read<UpdateFormCubit>().setType(newValue);
                        }
                      },
                    ),
                    const SizedBox(height: AppConstants.defaultPadding * 2),
                    AppButton(
                      label: widget.update == null
                          ? 'Add Update'
                          : 'Save Changes',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final newUpdate = Updates(
                            id: widget.update?.id ?? '',
                            title: _titleController.text,
                            description: _descriptionController.text,
                            date: formState.selectedDate,
                            type: formState.selectedType,
                          );
                          if (widget.update == null) {
                            context.read<UpdatesAdminCubit>().addUpdate(
                              newUpdate,
                            );
                          } else {
                            context.read<UpdatesAdminCubit>().updateUpdate(
                              widget.update!.id,
                              newUpdate,
                            );
                          }
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

IconData _typeIcon(UpdateType type) {
  switch (type) {
    case UpdateType.newCourse:
      return Icons.school_rounded;
    case UpdateType.event:
      return Icons.event_rounded;
    case UpdateType.resourceUpdate:
      return Icons.folder_special_rounded;
  }
}

String _typeLabel(UpdateType type) {
  switch (type) {
    case UpdateType.newCourse:
      return 'New Course';
    case UpdateType.event:
      return 'Event';
    case UpdateType.resourceUpdate:
      return 'Resource Update';
  }
}

