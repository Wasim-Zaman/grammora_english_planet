import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/user_updates/user_updates_cubit.dart';
import 'package:gep/cubits/user_updates/user_updates_state.dart';
import 'package:gep/models/updates.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/paginated_widget.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:gep/view/widgets/text_field_widget.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<UserUpdatesCubit>().fetchPage(0);
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

    final textColorSecondary = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return BlocBuilder<UserUpdatesCubit, UserUpdatesState>(
      builder: (context, state) {
        final updates = state.items;
        final isLoading = state.isLoading && updates.isEmpty;

        return AppScaffold(
          title: 'English Course Updates',
          // Bottom Navigation Bar with PaginatedWidget
          bottomNavigationBar: updates.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(
                    color: cardBg,
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
                            context.read<UserUpdatesCubit>().previousPage(),
                        onNext: () =>
                            context.read<UserUpdatesCubit>().nextPage(),
                        onPageSelected: (page) =>
                            context.read<UserUpdatesCubit>().goToPage(page),
                        onRefresh: () =>
                            context.read<UserUpdatesCubit>().refresh(),
                        currentPage: state.currentPage,
                        pageSize: 10,
                      ),
                    ),
                  ),
                )
              : null,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Search Input
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.defaultPadding,
                    12,
                    AppConstants.defaultPadding,
                    12,
                  ),
                  child: TextFieldWidget(
                    controller: _searchController,
                    labelText: 'Search updates',
                    hintText: 'Search updates…',
                    prefixIcon: Icons.search_rounded,
                    suffixIcon: state.searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              context.read<UserUpdatesCubit>().clearSearch();
                            },
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: textColorSecondary,
                            ),
                          )
                        : null,
                    onChanged: (v) =>
                        context.read<UserUpdatesCubit>().setSearchQuery(v),
                  ),
                ),
              ),

              // Content Layouts
              if (isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: PlaceholderWidgets.listPlaceholder(itemCount: 5),
                  ),
                )
              else if (state.error != null && updates.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
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
                      ],
                    ),
                  ),
                )
              else if (updates.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      state.searchQuery.isEmpty
                          ? 'No updates available'
                          : 'No matches for "${state.searchQuery}"',
                      style: theme.textTheme.titleMedium,
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
                      final update = updates[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _UpdateCard(update: update, index: index),
                      );
                    }, childCount: updates.length),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _UpdateCard extends StatelessWidget {
  final Updates update;
  final int index;

  const _UpdateCard({required this.update, required this.index});

  IconData _typeIcon() {
    switch (update.type) {
      case UpdateType.newCourse:
        return Icons.school_outlined;
      case UpdateType.event:
        return Icons.event_outlined;
      case UpdateType.resourceUpdate:
        return Icons.grid_view_rounded;
    }
  }

  String _typeLabel() {
    switch (update.type) {
      case UpdateType.newCourse:
        return 'COURSE';
      case UpdateType.event:
        return 'EVENT';
      case UpdateType.resourceUpdate:
        return 'UPDATE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = isDark
        ? AppColors.darkBodyText
        : AppColors.lightBodyText;
    final secondaryTextColor = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final tagBg = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.8);
    final tagBorderColor = isDark
        ? colorScheme.outline.withValues(alpha: 0.25)
        : colorScheme.outline.withValues(alpha: 0.15);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Type Tag & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: tagBorderColor, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_typeIcon(), size: 12, color: primaryTextColor),
                      const SizedBox(width: 4),
                      Text(
                        _typeLabel(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: primaryTextColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(update.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: secondaryTextColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              update.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: primaryTextColor,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),

            // Description
            Text(
              update.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: secondaryTextColor,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (20 + index * 15).ms).slideY(begin: 0.04, end: 0);
  }
}
