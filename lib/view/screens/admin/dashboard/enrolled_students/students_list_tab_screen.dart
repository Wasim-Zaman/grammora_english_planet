import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/enrolled_students_admin/enrolled_students_cubit.dart';
import 'package:gep/cubits/enrolled_students_admin/enrolled_students_state.dart';
import 'package:gep/models/enrolled_students.dart';
import 'package:gep/router/app_navigation.dart';
import 'package:gep/router/app_routes.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/admin_list_tile.dart';
import 'package:gep/view/widgets/app_button.dart';
import 'package:gep/view/widgets/app_dialog.dart';
import 'package:gep/view/widgets/paginated_widget.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:gep/view/widgets/text_field_widget.dart';
import 'package:material_ui/material_ui.dart';

class StudentsListTab extends StatefulWidget {
  const StudentsListTab({super.key});

  @override
  State<StudentsListTab> createState() => _StudentsListTabState();
}

class _StudentsListTabState extends State<StudentsListTab> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<EnrolledStudentsAdminCubit>().fetchPage(0);
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

    return BlocConsumer<EnrolledStudentsAdminCubit, EnrolledStudentsState>(
      listener: (context, state) {
        if (state.error != null && !state.isLoading && !state.isRefreshing) {
          TopSnackbar.error(context, state.error!);
        }
      },
      builder: (context, state) {
        final students = state.items;
        final isLoading = state.isLoading && students.isEmpty;

        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async =>
                        context.read<EnrolledStudentsAdminCubit>().refresh(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.all(AppConstants.defaultPadding),
                      children: [
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextFieldWidget(
                            controller: _searchController,
                            labelText: 'Search students',
                            hintText: 'Search students…',
                            prefixIcon: Icons.search_rounded,
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close_rounded,
                                        size: 18),
                                    color: textColorSecondary,
                                    onPressed: () {
                                      _searchController.clear();
                                      context
                                          .read<EnrolledStudentsAdminCubit>()
                                          .clearSearch();
                                    },
                                  )
                                : null,
                            onChanged: (v) => context
                                .read<EnrolledStudentsAdminCubit>()
                                .setSearchQuery(v),
                          ),
                        ),

                        // Header Label & Badge
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 12, left: 4, right: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.people_rounded,
                                    size: 16,
                                    color: textColorSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    state.searchQuery.isEmpty
                                        ? 'ENROLLED STUDENTS'
                                        : 'SEARCH RESULTS',
                                    style:
                                        theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.1,
                                      color: textColorSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              if (!isLoading && students.isNotEmpty)
                                Badge(
                                  label: Text('${students.length}'),
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
                        else if (state.error != null && students.isEmpty)
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
                                    'Failed to load students',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
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
                        else if (students.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_off_rounded,
                                    size: 36,
                                    color: textColorSecondary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    state.searchQuery.isEmpty
                                        ? 'No Students Found'
                                        : 'No matches for "${state.searchQuery}"',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.searchQuery.isEmpty
                                        ? 'Tap the + button below to add your first student'
                                        : '',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: textColorSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (state.searchQuery.isEmpty)
                                    AppButton(
                                      onPressed: () => _addStudent(context),
                                      label: 'Add New Student',
                                      expanded: false,
                                    ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: students.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final student = students[index];
                              return AdminListTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  child: Text(
                                    student.name.isNotEmpty
                                        ? student.name[0]
                                        : '?',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: student.name,
                                subtitle: student.level,
                                trailingActions: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 20),
                                    color: theme.colorScheme.primary,
                                    onPressed: () =>
                                        _editStudent(context, student),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 20,
                                    ),
                                    color: AppColors.error
                                        .withValues(alpha: 0.85),
                                    onPressed: () =>
                                        _confirmDelete(student),
                                  ),
                                ],
                                onTap: () =>
                                    _showStudentDetails(context, student),
                              );
                            },
                          ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
                if (students.isNotEmpty)
                  Container(
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
                        onPrevious: () => context
                            .read<EnrolledStudentsAdminCubit>()
                            .previousPage(),
                        onNext: () => context
                            .read<EnrolledStudentsAdminCubit>()
                            .nextPage(),
                        onPageSelected: (page) => context
                            .read<EnrolledStudentsAdminCubit>()
                            .goToPage(page),
                        onRefresh: () => context
                            .read<EnrolledStudentsAdminCubit>()
                            .refresh(),
                        currentPage: state.currentPage,
                        pageSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            Positioned(
              bottom: students.isNotEmpty ? 88 : 24,
              right: AppConstants.defaultPadding,
              child: FloatingActionButton.extended(
                onPressed: () => _addStudent(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Student'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editStudent(BuildContext context, EnrolledStudent student) async {
    final cubit = context.read<EnrolledStudentsAdminCubit>();
    final result = await AppNavigation.pushForResult<bool>(
      context,
      AppRoutes.kEditStudentRoute,
      extra: {
        'student': student,
        'service': cubit.service,
      },
    );

    if (!context.mounted) return;
    if (result == true) {
      TopSnackbar.success(context, 'Student updated successfully');
    }
  }

  void _showStudentDetails(BuildContext context, EnrolledStudent student) {
    AppNavigation.push(context, AppRoutes.kStudentDetailsRoute,
        extra: student);
  }

  void _addStudent(BuildContext context) async {
    final cubit = context.read<EnrolledStudentsAdminCubit>();
    final result = await AppNavigation.pushForResult<bool>(
      context,
      AppRoutes.kAddStudentRoute,
      extra: cubit.service,
    );

    if (!context.mounted) return;
    if (result == true) {
      TopSnackbar.success(context, 'Student added successfully');
    }
  }

  Future<void> _confirmDelete(EnrolledStudent student) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Delete Student',
      message: 'Are you sure you want to delete "${student.name}"?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      context.read<EnrolledStudentsAdminCubit>().deleteStudent(student.id);
    }
  }
}
