import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../../cubits/course_form/course_form_cubit.dart';
import '../../../../../cubits/course_form/course_form_state.dart';
import '../../../../../cubits/courses/courses_cubit.dart';
import '../../../../../cubits/courses/courses_state.dart';
import '../../../../../models/course_outline.dart';
import '../../../../../utils/snackbars.dart';
import '../../../../widgets/admin_list_tile.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_dialog.dart';
import '../../../../widgets/app_scaffold.dart';
import '../../../../widgets/paginated_widget.dart';
import '../../../../widgets/placeholder_widget.dart';
import '../../../../widgets/text_field_widget.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({super.key});

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<CoursesCubit>().fetchPage(0);
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

    return BlocConsumer<CoursesCubit, CoursesState>(
      listener: (context, state) {
        if (state.error != null && !state.isLoading && !state.isRefreshing) {
          TopSnackbar.error(context, state.error!);
        }
      },
      builder: (context, state) {
        final courses = state.items;
        final isLoading = state.isLoading && courses.isEmpty;

        return AppScaffold(
          title: 'Manage Courses',
          floatingActionButton: context.watch<CoursesCubit>().state.isLoading
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _showCourseSheet(context),
                  tooltip: 'Add Course',
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Course'),
                ),
          bottomNavigationBar: courses.isNotEmpty
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
                          context.read<CoursesCubit>().previousPage(),
                      onNext: () => context.read<CoursesCubit>().nextPage(),
                      onPageSelected: (page) =>
                          context.read<CoursesCubit>().goToPage(page),
                      onRefresh: () => context.read<CoursesCubit>().refresh(),
                      currentPage: state.currentPage,
                      pageSize: 10,
                    ),
                  ),
                )
              : null,
          body: RefreshIndicator(
            onRefresh: () async => context.read<CoursesCubit>().refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFieldWidget(
                    controller: _searchController,
                    labelText: 'Search courses',
                    hintText: 'Search courses…',
                    prefixIcon: Icons.search_rounded,
                    suffixIcon: state.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: textColorSecondary,
                            onPressed: () {
                              _searchController.clear();
                              context.read<CoursesCubit>().clearSearch();
                            },
                          )
                        : null,
                    onChanged: (v) =>
                        context.read<CoursesCubit>().setSearchQuery(v),
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
                            Icons.school_rounded,
                            size: 16,
                            color: textColorSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'AVAILABLE COURSES'
                                : 'SEARCH RESULTS',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: textColorSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (!isLoading && courses.isNotEmpty)
                        Badge(
                          label: Text('${courses.length}'),
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
                else if (state.error != null && courses.isEmpty)
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
                            'Failed to load courses',
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
                else if (courses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 36,
                            color: textColorSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'No Courses Found'
                                : 'No matches for "${state.searchQuery}"',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'Tap the + button below to add your first course'
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
                    itemCount: courses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return AdminListTile(
                        leadingIcon: Icons.auto_stories_rounded,
                        title: course.title,
                        subtitle: '${course.weeks.length} weeks duration',
                        trailingActions: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            color: theme.colorScheme.primary,
                            onPressed: () =>
                                _showCourseSheet(context, course: course),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                            ),
                            color: AppColors.error.withValues(alpha: 0.85),
                            onPressed: () => _deleteCourse(context, course),
                          ),
                        ],
                        onTap: () => _showCourseSheet(context, course: course),
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

  void _showCourseSheet(BuildContext context, {Course? course}) {
    final coursesCubit = context.read<CoursesCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: coursesCubit,
        child: FractionallySizedBox(
          heightFactor: 0.9,
          child: _CourseSheet(course: course),
        ),
      ),
    );
  }

  void _deleteCourse(BuildContext context, Course course) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Delete Course',
      message: 'Are you sure you want to delete "${course.title}"?',
      cancelLabel: 'Cancel',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      context.read<CoursesCubit>().deleteCourse(course.id!);
    }
  }
}

class _CourseSheet extends StatefulWidget {
  final Course? course;
  const _CourseSheet({this.course});

  @override
  State<_CourseSheet> createState() => _CourseSheetState();
}

class _CourseSheetState extends State<_CourseSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _courseTitle;

  @override
  void initState() {
    super.initState();
    _courseTitle = TextEditingController(text: widget.course?.title ?? '');
  }

  @override
  void dispose() {
    _courseTitle.dispose();
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

    return BlocProvider(
      create: (_) => CourseFormCubit(widget.course?.weeks ?? []),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: AppScaffold(
            title: widget.course == null ? 'Add Course' : 'Edit Course',
            body: BlocBuilder<CourseFormCubit, CourseFormState>(
              builder: (context, formState) {
                return Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    children: [
                      TextFieldWidget(
                        controller: _courseTitle,
                        labelText: 'Course Title',
                        validator: (v) => v == null || v.isEmpty
                            ? 'Enter course title'
                            : null,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      ..._buildWeeksList(
                        context,
                        formState,
                        isDark,
                        cardColor,
                        borderColor,
                      ),
                      const SizedBox(height: 12),
                      ActionChip(
                        avatar: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add Week'),
                        onPressed: () =>
                            context.read<CourseFormCubit>().addWeek(),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding * 2),
                      AppButton(
                        label: widget.course == null
                            ? 'Create Course'
                            : 'Save Changes',
                        onPressed: () => _submit(context),
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
      ),
    );
  }

  List<Widget> _buildWeeksList(
    BuildContext context,
    CourseFormState formState,
    bool isDark,
    Color cardColor,
    Color borderColor,
  ) {
    return formState.weeks.asMap().entries.map((entry) {
      final idx = entry.key;
      final weekData = entry.value;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Week ${idx + 1}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (formState.weeks.length > 1)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error.withValues(alpha: 0.85),
                      size: 18,
                    ),
                    onPressed: () =>
                        context.read<CourseFormCubit>().removeWeek(idx),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFieldWidget(
              controller: weekData.titleController,
              labelText: 'Week Title',
            ),
            const SizedBox(height: 12),
            ..._buildTopicsList(context, idx, weekData),
            const SizedBox(height: 8),
            ActionChip(
              avatar: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Topic'),
              onPressed: () =>
                  context.read<CourseFormCubit>().addTopic(idx),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildTopicsList(
    BuildContext context,
    int weekIndex,
    WeekFormData weekData,
  ) {
    return weekData.topicControllers.asMap().entries.map((entry) {
      final idx = entry.key;
      final controller = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextFieldWidget(
                controller: controller,
                labelText: 'Topic ${idx + 1}',
              ),
            ),
            if (weekData.topicControllers.length > 1)
              IconButton(
                icon: Icon(
                  Icons.remove_circle_outline_rounded,
                  color: AppColors.error.withValues(alpha: 0.7),
                  size: 20,
                ),
                onPressed: () => context
                    .read<CourseFormCubit>()
                    .removeTopic(weekIndex, idx),
              ),
          ],
        ),
      );
    }).toList();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final weeks = context.read<CourseFormCubit>().getWeeks();
    final course = Course(
      id: widget.course?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _courseTitle.text,
      weeks: weeks,
    );
    if (widget.course != null) {
      context.read<CoursesCubit>().updateCourse(course.id!, course);
    } else {
      context.read<CoursesCubit>().addCourse(course);
    }
    Navigator.pop(context);
  }
}
