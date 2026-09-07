import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/notes_categories/notes_categories_cubit.dart';
import 'package:gep/cubits/notes_categories/notes_categories_state.dart';
import 'package:gep/router/app_navigation.dart';
import 'package:gep/router/app_routes.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/app_search_field.dart';
import 'package:gep/view/widgets/paginated_widget.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:material_ui/material_ui.dart';

class NotesCategoriesScreen extends StatefulWidget {
  const NotesCategoriesScreen({super.key});

  @override
  State<NotesCategoriesScreen> createState() => _NotesCategoriesScreenState();
}

class _NotesCategoriesScreenState extends State<NotesCategoriesScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<NotesCategoriesCubit>().fetchPage(0);
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

    return BlocBuilder<NotesCategoriesCubit, NotesCategoriesState>(
      builder: (context, state) {
        final categories = state.items;
        final isLoading = state.isLoading && categories.isEmpty;

        return AppScaffold(
          title: 'Notes',
          bottomNavigationBar: categories.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border(
                      top: BorderSide(color: borderColor, width: 1),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding,
                        vertical: 10,
                      ),
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
                  ),
                )
              : null,
          body: RefreshIndicator(
            onRefresh: () async =>
                context.read<NotesCategoriesCubit>().refresh(),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Search
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.defaultPadding,
                      12,
                      AppConstants.defaultPadding,
                      12,
                    ),
                    child: AppSearchField(
                      controller: _searchController,
                      query: state.searchQuery,
                      labelText: 'Search categories',
                      hintText: 'Search categories…',
                      onChanged: (v) =>
                          context.read<NotesCategoriesCubit>().setSearchQuery(v),
                      onClear: () =>
                          context.read<NotesCategoriesCubit>().clearSearch(),
                    ),
                  ),
                ),

                // Header Label & Badge
                if (!isLoading)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.defaultPadding,
                        0,
                        AppConstants.defaultPadding,
                        12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.folder_copy_rounded,
                                size: 16,
                                color: textColorSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                state.searchQuery.isEmpty
                                    ? 'ALL CATEGORIES'
                                    : 'SEARCH RESULTS',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: textColorSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (categories.isNotEmpty)
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
                  ),

                if (isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: PlaceholderWidgets.listPlaceholder(),
                    ),
                  )
                else if (state.error != null && categories.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
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
                else if (categories.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_off_rounded,
                            size: 36,
                            color: textColorSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'No categories found'
                                : 'No matches for "${state.searchQuery}"',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.searchQuery.isEmpty
                                ? 'Check back later for new notes'
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
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.defaultPadding,
                      0,
                      AppConstants.defaultPadding,
                      16,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final category = categories[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _CategoryCard(
                            category: category,
                            index: index,
                            cardColor: cardColor,
                            borderColor: borderColor,
                          ),
                        );
                      }, childCount: categories.length),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String category;
  final int index;
  final Color cardColor;
  final Color borderColor;

  const _CategoryCard({
    required this.category,
    required this.index,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColorSecondary = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return GestureDetector(
      onTap: () =>
          AppNavigation.push(context, AppRoutes.kNotesRoute, extra: category),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
                child: Text(
                  category,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: textColorSecondary,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (30 + index * 20).ms).slideY(begin: 0.05, end: 0);
  }
}
