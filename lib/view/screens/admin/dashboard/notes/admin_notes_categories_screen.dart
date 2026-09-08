import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../../cubits/notes_categories/notes_categories_cubit.dart';
import '../../../../../cubits/notes_categories/notes_categories_state.dart';
import '../../../../../router/app_navigation.dart';
import '../../../../../router/app_routes.dart';
import '../../../../../utils/snackbars.dart';
import '../../../../widgets/admin_list_tile.dart';
import '../../../../widgets/app_dialog.dart';
import '../../../../widgets/app_scaffold.dart';
import '../../../../widgets/icon_button.dart';
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
      message: 'Are you sure you want to delete "$category"?',
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
          title: 'Categories',
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
                // Category Creation Card
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.folder_rounded,
                            size: 18,
                            color: isDark
                                ? AppColors.darkIcon
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'CREATE CATEGORY',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextFieldWidget(
                              controller: _categoryController,
                              labelText: 'Category Name',
                              prefixIcon: Icons.folder_open_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 45,
                            width: 45,
                            child: IconButtonWidget(
                              icon: Icons.add_rounded,
                              onPressed: _handleAddCategory,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: TextFieldWidget(
                    controller: _searchController,
                    labelText: 'Search categories',
                    hintText: 'Search categories…',
                    prefixIcon: Icons.search_rounded,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: secondaryText,
                            onPressed: () {
                              _searchController.clear();
                              context
                                  .read<NotesCategoriesCubit>()
                                  .clearSearch();
                            },
                          )
                        : null,
                    onChanged: (value) => context
                        .read<NotesCategoriesCubit>()
                        .setSearchQuery(value),
                  ),
                ),

                // Section Label & Counter
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.folder_copy_rounded,
                            size: 14,
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

                // Body States: Loading, Error, Empty, or List Content
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
                            size: 36,
                            color: secondaryText,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No Categories Found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'Add a new category above to get started'
                                : 'No matches for "${state.searchQuery}"',
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
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return AdminListTile(
                        leadingIcon: Icons.folder_rounded,
                        title: category,
                        borderRadius: 14,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 2,
                        ),
                        trailingActions: [
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                            ),
                            color: AppColors.error.withValues(alpha: 0.8),
                            onPressed: () => _handleDeleteCategory(category),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: secondaryText,
                          ),
                        ],
                        onTap: () => AppNavigation.push(
                          context,
                          AppRoutes.kAddNotesRoute,
                          extra: category,
                          queryParameters: {'category': category},
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
