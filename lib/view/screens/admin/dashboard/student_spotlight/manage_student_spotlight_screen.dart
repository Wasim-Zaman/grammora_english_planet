import 'dart:io';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/constants.dart';
import '../../../../../cubits/admin/admin_cubit.dart';
import '../../../../../cubits/student_spotlight/student_spotlight_cubit.dart';
import '../../../../../cubits/student_spotlight/student_spotlight_image_cubit.dart';
import '../../../../../cubits/student_spotlight/student_spotlight_state.dart';
import '../../../../../cubits/student_spotlight_form/spotlight_editor_cubit.dart';
import '../../../../../cubits/student_spotlight_form/student_spotlight_form_cubit.dart';
import '../../../../../cubits/student_spotlight_form/student_spotlight_form_state.dart';
import '../../../../../models/enrolled_students.dart';
import '../../../../../models/student_spotlight.dart';
import '../../../../../services/storage/storage_service.dart';
import '../../../../../services/student_spotlight/student_spotlight_service.dart';
import '../../../../../utils/snackbars.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_dialog.dart';
import '../../../../widgets/app_scaffold.dart';
import '../../../../widgets/app_search_field.dart';
import '../../../../widgets/cached_image_widget.dart';
import '../../../../widgets/paginated_widget.dart';
import '../../../../widgets/placeholder_widget.dart';
import '../../../../widgets/text_field_widget.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:material_ui/material_ui.dart';

class ManageStudentSpotlightScreen extends StatefulWidget {
  const ManageStudentSpotlightScreen({super.key});

  @override
  State<ManageStudentSpotlightScreen> createState() =>
      _ManageStudentSpotlightScreenState();
}

class _ManageStudentSpotlightScreenState
    extends State<ManageStudentSpotlightScreen> {
  late final TextEditingController _searchController;

  static const List<String> _filterTabs = [
    'All',
    'Student of the Month',
    'Student of the Year',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<StudentSpotlightCubit>().fetchPage(0);
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
    final secondaryTextColor = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => StudentSpotlightFormCubit(
            StudentSpotlightService(),
            StorageService(),
          ),
        ),
        BlocProvider(create: (_) => StudentSpotlightImageCubit()),
      ],
      child: BlocConsumer<StudentSpotlightCubit, StudentSpotlightState>(
        listener: (context, state) {
          if (state.error != null && !state.isLoading && !state.isRefreshing) {
            TopSnackbar.error(context, state.error!);
          }
        },
        builder: (context, state) {
          final spotlights = state.items;
          final isLoading = state.isLoading && spotlights.isEmpty;

          return BlocListener<
            StudentSpotlightFormCubit,
            StudentSpotlightFormState
          >(
            listener: (context, formState) {
              if (formState is StudentSpotlightFormSuccess) {
                TopSnackbar.success(context, formState.message);
                context.read<StudentSpotlightCubit>().refresh();
              } else if (formState is StudentSpotlightFormFailure) {
                TopSnackbar.error(context, formState.error);
              }
            },
            child: AppScaffold(
              title: 'Student Spotlight',
              floatingActionButton: isLoading
                  ? null
                  : FloatingActionButton.extended(
                      onPressed: () => _showAddEditSheet(context),
                      tooltip: 'Add Star Student',
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        'Add Star Student',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
              bottomNavigationBar: spotlights.isNotEmpty
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
                          onPrevious: () => context
                              .read<StudentSpotlightCubit>()
                              .previousPage(),
                          onNext: () =>
                              context.read<StudentSpotlightCubit>().nextPage(),
                          onPageSelected: (page) => context
                              .read<StudentSpotlightCubit>()
                              .goToPage(page),
                          onRefresh: () =>
                              context.read<StudentSpotlightCubit>().refresh(),
                          currentPage: state.currentPage,
                          pageSize: 10,
                        ),
                      ),
                    )
                  : null,
              body: RefreshIndicator(
                onRefresh: () async =>
                    context.read<StudentSpotlightCubit>().refresh(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppSearchField(
                        controller: _searchController,
                        query: state.searchQuery,
                        labelText: 'Search star students',
                        hintText: 'Search by student name or batch…',
                        onChanged: (q) => context
                            .read<StudentSpotlightCubit>()
                            .setSearchQuery(q),
                        onClear: () =>
                            context.read<StudentSpotlightCubit>().clearSearch(),
                      ),
                    ),

                    // Filter tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: _filterTabs.map((tab) {
                          final isSelected = state.awardFilter == tab;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(tab),
                              selected: isSelected,
                              showCheckmark: false,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
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
                                borderRadius: BorderRadius.circular(10),
                              ),
                              onSelected: (_) {
                                context
                                    .read<StudentSpotlightCubit>()
                                    .setAwardFilter(tab);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Section Title
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                        left: 4,
                        right: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                AppFeatureIcons.spotlight,
                                size: 16,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                state.searchQuery.isEmpty
                                    ? 'HONORED STUDENTS'
                                    : 'SEARCH RESULTS',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          if (!isLoading && spotlights.isNotEmpty)
                            Badge(
                              label: Text('${spotlights.length}'),
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

                    // Content States
                    if (isLoading)
                      PlaceholderWidgets.listPlaceholder()
                    else if (state.error != null && spotlights.isEmpty)
                      _buildErrorState(theme, isDark)
                    else if (spotlights.isEmpty)
                      _buildEmptyState(theme, isDark, state.searchQuery)
                    else
                      ...spotlights.map(
                        (spotlight) => _buildSpotlightCard(
                          context,
                          spotlight,
                          theme,
                          isDark,
                          cardColor,
                          borderColor,
                          secondaryTextColor,
                        ),
                      ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpotlightCard(
    BuildContext context,
    StudentSpotlightModel spotlight,
    ThemeData theme,
    bool isDark,
    Color cardColor,
    Color borderColor,
    Color secondaryTextColor,
  ) {
    final isMonth = spotlight.awardTitle.toLowerCase().contains('month');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: spotlight.isFeatured
              ? AppColors.secondary.withValues(alpha: 0.45)
              : borderColor,
          width: spotlight.isFeatured ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Info Row: Student Avatar, Name, Award Badges
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Photo
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isMonth ? AppColors.accent : AppColors.secondary,
                      width: 2.2,
                    ),
                  ),
                  child: ClipOval(
                    child: CachedImageWidget(
                      imageUrl: spotlight.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Name & Badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // Award Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isMonth
                                  ? AppColors.accent.withValues(alpha: 0.15)
                                  : AppColors.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.award,
                                  size: 13,
                                  color: isMonth
                                      ? (isDark
                                            ? AppColors.accent
                                            : AppColors.warning)
                                      : AppColors.secondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  spotlight.awardTitle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isMonth
                                        ? (isDark
                                              ? AppColors.accent
                                              : AppColors.warning)
                                        : AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Period Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkNeutral
                                  : AppColors.lightNeutral,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              spotlight.period,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        spotlight.studentName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (spotlight.courseOrBatch.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              AppFeatureIcons.courses,
                              size: 13,
                              color: secondaryTextColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                spotlight.courseOrBatch,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: secondaryTextColor,
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
          ),

          // Motivational Quote / Message
          if (spotlight.quoteOrMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkNeutral.withValues(alpha: 0.6)
                      : AppColors.lightNeutral.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        spotlight.quoteOrMessage,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? AppColors.darkBodyText
                              : AppColors.lightBodyText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Achievements Highlights
          if (spotlight.achievementHighlights.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      spotlight.achievementHighlights,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 6),
          const Divider(height: 1),

          // Bottom Actions Row: Featured Toggle + Edit + Delete
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch.adaptive(
                        value: spotlight.isFeatured,
                        activeTrackColor: AppColors.secondary,
                        onChanged: (val) {
                          context.read<StudentSpotlightCubit>().toggleFeatured(
                            spotlight.id,
                            val,
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          spotlight.isFeatured ? 'Featured on Home' : 'Hidden',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: spotlight.isFeatured
                                ? AppColors.secondary
                                : secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Edit & Delete Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      color: AppColors.secondary,
                      tooltip: 'Edit',
                      onPressed: () =>
                          _showAddEditSheet(context, spotlight: spotlight),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      color: AppColors.error,
                      tooltip: 'Delete',
                      onPressed: () => _confirmDelete(context, spotlight),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark, String searchQuery) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkNeutral : AppColors.lightNeutral,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.award,
                size: 42,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'No star students added yet'
                  : 'No students match "$searchQuery"',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              searchQuery.isEmpty
                  ? 'Recognize top performers to motivate the entire academy.'
                  : 'Try searching with another keyword or clear search.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
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

  Widget _buildErrorState(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load star students',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Retry',
              expanded: false,
              onPressed: () => context.read<StudentSpotlightCubit>().refresh(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    StudentSpotlightModel spotlight,
  ) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Remove Star Student?',
      message:
          'Are you sure you want to remove "${spotlight.studentName}" from the Student Spotlight? This action cannot be undone.',
      confirmLabel: 'Remove',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<StudentSpotlightCubit>().deleteSpotlight(spotlight.id);
      TopSnackbar.success(
        context,
        '${spotlight.studentName} removed from spotlight',
      );
    }
  }

  void _showAddEditSheet(
    BuildContext context, {
    StudentSpotlightModel? spotlight,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<StudentSpotlightFormCubit>()),
          BlocProvider.value(value: context.read<StudentSpotlightImageCubit>()),
          BlocProvider.value(value: context.read<AdminCubit>()),
          BlocProvider(
            create: (_) => SpotlightEditorCubit(
              initialAward: spotlight?.awardTitle ?? 'Student of the Month',
              initialFeatured: spotlight?.isFeatured ?? true,
            ),
          ),
        ],
        child: _AddEditSpotlightSheet(spotlight: spotlight),
      ),
    );
  }
}

class _AddEditSpotlightSheet extends StatefulWidget {
  final StudentSpotlightModel? spotlight;

  const _AddEditSpotlightSheet({this.spotlight});

  @override
  State<_AddEditSpotlightSheet> createState() => _AddEditSpotlightSheetState();
}

class _AddEditSpotlightSheetState extends State<_AddEditSpotlightSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _periodController;
  late final TextEditingController _courseController;
  late final TextEditingController _quoteController;
  late final TextEditingController _highlightsController;

  static const List<String> _awardOptions = [
    'Student of the Month',
    'Student of the Year',
    'Star Performer',
    'Most Dedicated Student',
  ];

  Future<void> _pickStudent(BuildContext context) async {
    final selected = await showModalBottomSheet<EnrolledStudent>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<AdminCubit>(),
        child: const _StudentSelectionBottomSheet(),
      ),
    );

    if (selected != null && mounted) {
      context.read<SpotlightEditorCubit>().setStudent(selected);
      _nameController.text = selected.name;
      if (selected.level.isNotEmpty) {
        _courseController.text = selected.level;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final item = widget.spotlight;
    _nameController = TextEditingController(text: item?.studentName ?? '');
    _periodController = TextEditingController(
      text:
          item?.period ??
          '${_getMonthName(DateTime.now().month)} ${DateTime.now().year}',
    );
    _courseController = TextEditingController(text: item?.courseOrBatch ?? '');
    _quoteController = TextEditingController(text: item?.quoteOrMessage ?? '');
    _highlightsController = TextEditingController(
      text: item?.achievementHighlights ?? '',
    );

    context.read<StudentSpotlightImageCubit>().reset();
  }

  static String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _periodController.dispose();
    _courseController.dispose();
    _quoteController.dispose();
    _highlightsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final primaryTextColor = isDark
        ? AppColors.darkBodyText
        : AppColors.lightBodyText;
    final secondaryTextColor = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return BlocConsumer<StudentSpotlightFormCubit, StudentSpotlightFormState>(
      listener: (context, state) {
        if (state is StudentSpotlightFormSuccess) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, formState) {
        final isSaving = formState is StudentSpotlightFormLoading;

        return BlocBuilder<SpotlightEditorCubit, SpotlightEditorState>(
          builder: (context, editorState) {
            return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.spotlight == null
                                ? 'Add Star Student'
                                : 'Edit Star Student',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Recognize outstanding achievements and progress',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: secondaryTextColor,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: secondaryTextColor,
                      style: IconButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.darkNeutral
                            : AppColors.lightNeutral,
                      ),
                      onPressed: isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Photo Picker (Circular with camera icon)
                Center(
                  child:
                      BlocBuilder<
                        StudentSpotlightImageCubit,
                        StudentSpotlightImageState
                      >(
                        builder: (context, imgState) {
                          final isProcessing =
                              imgState is StudentSpotlightImageProcessing;
                          final File? pickedFile =
                              imgState is StudentSpotlightImageSuccess
                              ? imgState.imageFile
                              : null;
                          final hasExisting =
                              widget.spotlight != null &&
                              widget.spotlight!.imageUrl.isNotEmpty;

                          return GestureDetector(
                            onTap: isSaving || isProcessing
                                ? null
                                : () => context
                                      .read<StudentSpotlightImageCubit>()
                                      .pickAndProcessPhoto(context),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.secondary,
                                      width: 2.2,
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.secondary.withValues(
                                          alpha: isDark ? 0.2 : 0.08,
                                        ),
                                        isDark
                                            ? AppColors.darkNeutral
                                            : AppColors.lightNeutral,
                                      ],
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: isProcessing
                                        ? const Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppColors.secondary),
                                              ),
                                            ),
                                          )
                                        : pickedFile != null
                                        ? Image.file(
                                            pickedFile,
                                            fit: BoxFit.cover,
                                          )
                                        : hasExisting
                                        ? CachedImageWidget(
                                            imageUrl:
                                                widget.spotlight!.imageUrl,
                                            fit: BoxFit.cover,
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Iconsax.camera,
                                                size: 26,
                                                color: AppColors.secondary,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Add Photo',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: cardColor,
                                        width: 2.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.15,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.edit_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ),
                const SizedBox(height: 20),

                // Quick Select Enrolled Student
                _StudentPickerField(
                  selectedStudent: editorState.selectedStudent,
                  onSelectStudent: () => _pickStudent(context),
                  onClear: () {
                    context.read<SpotlightEditorCubit>().clearStudent();
                    _nameController.clear();
                  },
                ),
                const SizedBox(height: 14),

                if (editorState.selectedStudent == null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: borderColor.withValues(alpha: 0.7),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'OR ENTER MANUALLY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: secondaryTextColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: borderColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],

                // Student Name
                TextFieldWidget(
                  controller: _nameController,
                  labelText: 'Student Full Name *',
                  hintText: 'e.g. John Doe',
                  prefixIcon: Iconsax.user,
                ),
                const SizedBox(height: 14),

                // Award Title Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkNeutral
                        : AppColors.lightNeutral,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 2),
                        child: Text(
                          'Honor / Award Title *',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _awardOptions.contains(editorState.awardTitle)
                              ? editorState.awardTitle
                              : _awardOptions.first,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.secondary,
                          ),
                          dropdownColor: cardColor,
                          items: _awardOptions.map((opt) {
                            final isYear = opt.contains('Year');
                            return DropdownMenuItem<String>(
                              value: opt,
                              child: Row(
                                children: [
                                  Icon(
                                    isYear ? Iconsax.cup : Iconsax.award,
                                    size: 18,
                                    color: isYear
                                        ? (isDark
                                              ? AppColors.accent
                                              : AppColors.warning)
                                        : AppColors.secondary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    opt,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              context.read<SpotlightEditorCubit>().setAwardTitle(val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Recognition Period / Month (Full width so Month and Year never truncate)
                TextFieldWidget(
                  controller: _periodController,
                  labelText: 'Month / Session *',
                  hintText: 'e.g. September 2026',
                  prefixIcon: Iconsax.calendar_1,
                ),
                const SizedBox(height: 14),

                // Course / Batch / Level
                TextFieldWidget(
                  controller: _courseController,
                  labelText: 'Course / Batch / Level',
                  hintText: 'e.g. Spoken English Basic',
                  prefixIcon: AppFeatureIcons.courses,
                ),
                const SizedBox(height: 14),

                // Motivational Quote / Message
                TextFieldWidget(
                  controller: _quoteController,
                  labelText: 'Motivational Words / Quote',
                  hintText:
                      'e.g. "Hard work and consistency always shine through."',
                  prefixIcon: Icons.format_quote_rounded,
                  maxLines: 2,
                ),
                const SizedBox(height: 14),

                // Achievement Highlights
                TextFieldWidget(
                  controller: _highlightsController,
                  labelText: 'Key Highlights / Achievements',
                  hintText: 'e.g. 100% Attendance • Top Academic Score',
                  prefixIcon: Icons.star_outline_rounded,
                ),
                const SizedBox(height: 14),

                // Featured Switch Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkNeutral
                        : AppColors.lightNeutral,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isDark ? AppColors.accent : AppColors.warning)
                              .withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          Iconsax.star,
                          size: 19,
                          color: isDark ? AppColors.accent : AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Feature on Home Spotlight',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Show in the top motivation card on user dashboard',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: secondaryTextColor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch.adaptive(
                        value: editorState.isFeatured,
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppColors.secondary,
                        onChanged: (val) =>
                            context.read<SpotlightEditorCubit>().setFeatured(val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Submit Button
                AppButton(
                  label: widget.spotlight == null
                      ? 'Add Star Student'
                      : 'Update Star Student',
                  icon: Icon(
                    widget.spotlight == null
                        ? Iconsax.add_circle
                        : Iconsax.tick_circle,
                    size: 20,
                    color: Colors.white,
                  ),
                  isLoading: isSaving,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  height: 52,
                  onPressed: isSaving ? null : () => _handleSave(context),
                ),
              ],
            ),
          ),
        );
          },
        );
      },
    );
  }

  void _handleSave(BuildContext context) {
    final imageState = context.read<StudentSpotlightImageCubit>().state;
    final File? pickedImage = imageState is StudentSpotlightImageSuccess
        ? imageState.imageFile
        : null;

    final editorState = context.read<SpotlightEditorCubit>().state;

    context.read<StudentSpotlightFormCubit>().save(
      studentName: _nameController.text,
      awardTitle: editorState.awardTitle,
      period: _periodController.text,
      courseOrBatch: _courseController.text,
      quoteOrMessage: _quoteController.text,
      achievementHighlights: _highlightsController.text,
      isFeatured: editorState.isFeatured,
      imageFile: pickedImage,
      existingSpotlight: widget.spotlight,
    );
  }
}

class _StudentPickerField extends StatelessWidget {
  final EnrolledStudent? selectedStudent;
  final VoidCallback onSelectStudent;
  final VoidCallback onClear;

  const _StudentPickerField({
    required this.selectedStudent,
    required this.onSelectStudent,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.darkBodyText
        : AppColors.lightBodyText;
    final secondaryTextColor = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    if (selectedStudent != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.4),
            width: 1.3,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: AppColors.secondary,
              child: Text(
                selectedStudent!.name.isNotEmpty
                    ? selectedStudent!.name[0].toUpperCase()
                    : 'S',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          selectedStudent!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'LINKED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (selectedStudent!.level.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      selectedStudent!.level,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: secondaryTextColor,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              color: secondaryTextColor,
              tooltip: 'Clear selection',
              onPressed: onClear,
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onSelectStudent,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkNeutral
              : AppColors.secondary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : AppColors.secondary.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Iconsax.user_search,
                size: 20,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Enrolled Student',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to choose from registered students list',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentSelectionBottomSheet extends StatefulWidget {
  const _StudentSelectionBottomSheet();

  @override
  State<_StudentSelectionBottomSheet> createState() =>
      _StudentSelectionBottomSheetState();
}

class _StudentSelectionBottomSheetState
    extends State<_StudentSelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();

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
    final primaryTextColor = isDark
        ? AppColors.darkBodyText
        : AppColors.lightBodyText;
    final secondaryTextColor = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return BlocProvider(
      create: (_) => StudentSearchCubit(),
      child: Builder(
        builder: (context) {
          return Material(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            clipBehavior: Clip.antiAlias,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Student',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          color: secondaryTextColor,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),

                  // Search Field
                  BlocBuilder<StudentSearchCubit, String>(
                    builder: (context, searchQuery) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: AppSearchField(
                          controller: _searchController,
                          query: searchQuery,
                          labelText: 'Search Students',
                          hintText: 'Search by name or level...',
                          onChanged: (val) {
                            context.read<StudentSearchCubit>().setQuery(val);
                          },
                          onClear: () {
                            context.read<StudentSearchCubit>().clear();
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 6),

                  // List of Enrolled Students Stream
                  Expanded(
                    child: StreamBuilder<List<EnrolledStudent>>(
                      stream: context
                          .read<AdminCubit>()
                          .getEnrolledStudentsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Failed to load students',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          );
                        }

                        final students = snapshot.data ?? [];
                        return BlocBuilder<StudentSearchCubit, String>(
                          builder: (context, searchQuery) {
                            final filtered = students.where((s) {
                              if (searchQuery.isEmpty) return true;
                              final nameMatch = s.name.toLowerCase().contains(
                                    searchQuery,
                                  );
                              final levelMatch = s.level.toLowerCase().contains(
                                    searchQuery,
                                  );
                              final fatherMatch =
                                  s.fatherName.toLowerCase().contains(
                                        searchQuery,
                                      );
                              return nameMatch || levelMatch || fatherMatch;
                            }).toList();

                            if (filtered.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Iconsax.user_remove,
                                        size: 44,
                                        color: secondaryTextColor,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        searchQuery.isEmpty
                                            ? 'No enrolled students found'
                                            : 'No students matching "$searchQuery"',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: secondaryTextColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              itemCount: filtered.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: borderColor.withValues(alpha: 0.5),
                              ),
                              itemBuilder: (context, index) {
                                final student = filtered[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        AppColors.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    child: Text(
                                      student.name.isNotEmpty
                                          ? student.name[0].toUpperCase()
                                          : 'S',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    student.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  subtitle: student.level.isNotEmpty
                                      ? Text(
                                          student.level,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: secondaryTextColor,
                                          ),
                                        )
                                      : null,
                                  trailing: Icon(
                                    Icons.chevron_right_rounded,
                                    size: 20,
                                    color: secondaryTextColor,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop(student);
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
