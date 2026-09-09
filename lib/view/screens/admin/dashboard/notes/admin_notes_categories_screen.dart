import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../../cubits/notes_categories/notes_categories_cubit.dart';
import '../../../../../cubits/notes_categories/notes_categories_state.dart';
import '../../../../../router/app_navigation.dart';
import '../../../../../router/app_routes.dart';
import '../../../../../utils/snackbars.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_dialog.dart';
import '../../../../widgets/app_scaffold.dart';
import '../../../../widgets/app_search_field.dart';
import '../../../../widgets/paginated_widget.dart';
import '../../../../widgets/placeholder_widget.dart';
import '../../../../widgets/text_field_widget.dart';

class AdminNotesCategoriesScreen extends StatefulWidget {
  const AdminNotesCategoriesScreen({super.key});

  @override
  State<AdminNotesCategoriesScreen> createState() =>
      _AdminNotesCategoriesScreenState();
}

class _AdminNotesCategoriesScreenState
    extends State<AdminNotesCategoriesScreen> {
  late final TextEditingController _categoryController;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController();
    _searchController = TextEditingController();
    context.read<NotesCategoriesCubit>().fetchPage(0);
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleAddCategory() {
    final text = _categoryController.text.trim();
    if (text.isNotEmpty) {
      context.read<NotesCategoriesCubit>().addCategory(text);
      _categoryController.clear();
      FocusScope.of(context).unfocus();
    } else {
      TopSnackbar.info(context, 'Please enter a category name');
    }
  }

  Future<void> _handleDeleteCategory(String category) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Delete Category',
      message:
          'Are you sure you want to delete "$category"? All notes under this category will also be deleted.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      context.read<NotesCategoriesCubit>().deleteCategory(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final secondaryText = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return BlocConsumer<NotesCategoriesCubit, NotesCategoriesState>(
      listener: (context, state) {
        if (state.error != null && !state.isLoading && !state.isRefreshing) {
          TopSnackbar.error(context, state.error!);
        }
      },
      builder: (context, state) {
        final categories = state.items;
        final isLoading = state.isLoading && categories.isEmpty;

        return AppScaffold(
          title: 'Notes Management',
          bottomNavigationBar: categories.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cardBg,
                    border: Border(top: BorderSide(color: borderColor)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: PaginatedWidget(
                      isLoading: state.isLoading || state.isRefreshing,
                      hasPrevious: state.currentPage > 0,
                      hasNext: state.hasMore,
                      onPrevious: () =>
                          context.read<NotesCategoriesCubit>().previousPage(),
                      onNext: () =>
                          context.read<NotesCategoriesCubit>().nextPage(),
                      onPageSelected: (page) =>
                          context.read<NotesCategoriesCubit>().goToPage(page),
                      onRefresh: () =>
                          context.read<NotesCategoriesCubit>().refresh(),
                      currentPage: state.currentPage,
                      pageSize: 15,
                    ),
                  ),
                )
              : null,
          body: RefreshIndicator(
            onRefresh: () async =>
                context.read<NotesCategoriesCubit>().refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                // Modern Category Creation Card
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.2 : 0.03,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.create_new_folder_rounded,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'NEW NOTE CATEGORY',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFieldWidget(
                        controller: _categoryController,
                        labelText: 'Category Name',
                        hintText: 'e.g. Mathematics, Operating Systems…',
                        prefixIcon: Icons.folder_open_rounded,
                        onFieldSubmitted: (_) => _handleAddCategory(),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Create Category',
                        icon: const Icon(Icons.add_rounded),
                        onPressed: _handleAddCategory,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 200.ms),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: AppSearchField(
                    controller: _searchController,
                    query: state.searchQuery,
                    labelText: 'Search categories',
                    hintText: 'Search categories…',
                    onChanged: (v) => context
                        .read<NotesCategoriesCubit>()
                        .setSearchQuery(v),
                    onClear: () =>
                        context.read<NotesCategoriesCubit>().clearSearch(),
                  ),
                ),

                // Section Header & Counter
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.folder_copy_rounded,
                            size: 16,
                            color: secondaryText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'ALL CATEGORIES'
                                : 'SEARCH RESULTS',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                      if (!isLoading && categories.isNotEmpty)
                        Badge(
                          label: Text('${categories.length}'),
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

                // Body States
                if (isLoading)
                  PlaceholderWidgets.listPlaceholder()
                else if (state.error != null && categories.isEmpty)
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
                            'Failed to load categories',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (categories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_off_rounded,
                            size: 40,
                            color: secondaryText,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'No Categories Found'
                                : 'No matches for "${state.searchQuery}"',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'Add a new category above to get started'
                                : '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: secondaryText,
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
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.03,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => AppNavigation.push(
                              context,
                              AppRoutes.kAddNotesRoute,
                              extra: category,
                              queryParameters: {'category': category},
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.folder_rounded,
                                      size: 22,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          category,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Manage & upload notes',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: secondaryText,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 20,
                                    ),
                                    color: AppColors.error.withValues(
                                      alpha: 0.85,
                                    ),
                                    onPressed: () =>
                                        _handleDeleteCategory(category),
                                    tooltip: 'Delete Category',
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: secondaryText,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: (20 + index * 15).ms)
                          .slideY(begin: 0.05, end: 0);
                    },
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
