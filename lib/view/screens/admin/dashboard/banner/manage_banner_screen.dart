import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/banner/banner_image_cubit.dart';
import 'package:gep/cubits/banner_form/banner_form_cubit.dart';
import 'package:gep/cubits/banners/banners_cubit.dart';
import 'package:gep/cubits/banners/banners_state.dart';
import 'package:gep/models/banner.dart';
import 'package:gep/services/banner/banner_service.dart';
import 'package:gep/services/storage/storage_service.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/app_button.dart';
import 'package:gep/view/widgets/app_dialog.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/app_search_field.dart';
import 'package:gep/view/widgets/cached_image_widget.dart';
import 'package:gep/view/widgets/paginated_widget.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:gep/view/widgets/text_field_widget.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:material_ui/material_ui.dart';

class ManageBannerScreen extends StatefulWidget {
  const ManageBannerScreen({super.key});

  @override
  State<ManageBannerScreen> createState() => _ManageBannerScreenState();
}

class _ManageBannerScreenState extends State<ManageBannerScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<BannersCubit>().fetchPage(0);
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

    return BlocProvider(
      create: (_) => BannerFormCubit(BannerService(), StorageService()),
      child: BlocConsumer<BannersCubit, BannersState>(
        listener: (context, state) {
          if (state.error != null && !state.isLoading && !state.isRefreshing) {
            TopSnackbar.error(context, state.error!);
          }
        },
        builder: (context, state) {
          final banners = state.items;
          final isLoading = state.isLoading && banners.isEmpty;

          return BlocListener<BannerFormCubit, BannerFormState>(
            listener: (context, formState) {
              if (formState is BannerFormSuccess) {
                TopSnackbar.success(context, formState.message);
                context.read<BannersCubit>().refresh();
              } else if (formState is BannerFormFailure) {
                TopSnackbar.error(context, formState.error);
              }
            },
            child: AppScaffold(
              title: 'Manage Banners',
              floatingActionButton: isLoading
                  ? null
                  : FloatingActionButton.extended(
                      onPressed: () => _showAddEditSheet(context),
                      tooltip: 'Add Banner',
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Banner'),
                    ),
              bottomNavigationBar: banners.isNotEmpty
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
                              context.read<BannersCubit>().previousPage(),
                          onNext: () => context.read<BannersCubit>().nextPage(),
                          onPageSelected: (page) =>
                              context.read<BannersCubit>().goToPage(page),
                          onRefresh: () =>
                              context.read<BannersCubit>().refresh(),
                          currentPage: state.currentPage,
                          pageSize: 10,
                        ),
                      ),
                    )
                  : null,
              body: RefreshIndicator(
                onRefresh: () async => context.read<BannersCubit>().refresh(),
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
                        labelText: 'Search banners',
                        hintText: 'Search banners…',
                        onChanged: (q) =>
                            context.read<BannersCubit>().setSearchQuery(q),
                        onClear: () =>
                            context.read<BannersCubit>().clearSearch(),
                      ),
                    ),

                    // Section Header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Iconsax.gallery,
                                size: 16,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                state.searchQuery.isEmpty
                                    ? 'AVAILABLE BANNERS'
                                    : 'SEARCH RESULTS',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          if (!isLoading && banners.isNotEmpty)
                            Badge(
                              label: Text('${banners.length}'),
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
                    else if (state.error != null && banners.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 40,
                                color: AppColors.error,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Failed to load banners',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkBodyText
                                      : AppColors.lightBodyText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.error!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (banners.isEmpty)
                      _EmptyState(
                        searchQuery: state.searchQuery,
                        onAdd: () => _showAddEditSheet(context),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: banners.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final banner = banners[index];
                          return _BannerCard(
                            banner: banner,
                            onEdit: () =>
                                _showAddEditSheet(context, banner: banner),
                            onDelete: () => _confirmDelete(context, banner),
                          );
                        },
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

  void _showAddEditSheet(BuildContext context, {BannerModel? banner}) {
    final bannerFormCubit = context.read<BannerFormCubit>();
    bannerFormCubit.reset();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: bannerFormCubit),
          BlocProvider(create: (_) => BannerImageCubit()),
        ],
        child: AddEditBannerSheet(banner: banner),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, BannerModel banner) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Delete Banner',
      message: 'Are you sure you want to delete "${banner.title}"?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<BannerFormCubit>().delete(banner);
    }
  }
}

class _BannerCard extends StatelessWidget {
  final BannerModel banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BannerCard({
    required this.banner,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final primaryTextColor = isDark
        ? AppColors.darkBodyText
        : AppColors.lightBodyText;
    final actionColor = isDark ? AppColors.secondary : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2.5,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: CachedImageWidget(
                imageUrl: banner.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    banner.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: actionColor,
                  ),
                  onPressed: onEdit,
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.error,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddEditBannerSheet extends StatefulWidget {
  final BannerModel? banner;

  const AddEditBannerSheet({super.key, this.banner});

  @override
  State<AddEditBannerSheet> createState() => _AddEditBannerSheetState();
}

class _AddEditBannerSheetState extends State<AddEditBannerSheet> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.banner?.title ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    final imageState = context.read<BannerImageCubit>().state;
    final imageFile =
        imageState is BannerImageSuccess ? imageState.imageFile : null;

    context.read<BannerFormCubit>().save(
          title: _titleController.text,
          imageFile: imageFile,
          existingBanner: widget.banner,
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
    final secondaryTextColor = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;
    final primaryTextColor = isDark
        ? AppColors.darkBodyText
        : AppColors.lightBodyText;
    final accentColor = isDark ? AppColors.secondary : AppColors.primary;

    final isEditing = widget.banner != null;

    return BlocConsumer<BannerFormCubit, BannerFormState>(
      listener: (context, state) {
        if (state is BannerFormSuccess) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, formState) {
        final isSaving = formState is BannerFormLoading;

        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Edit Banner' : 'Add Banner',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: secondaryTextColor,
                        onPressed: isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFieldWidget(
                    controller: _titleController,
                    labelText: 'Banner Title',
                    hintText: 'Enter banner title…',
                    prefixIcon: Icons.title_rounded,
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<BannerImageCubit, BannerImageState>(
                    builder: (context, state) {
                      final isProcessing = state is BannerImageProcessing;
                      final File? pickedFile = state is BannerImageSuccess
                          ? state.imageFile
                          : null;
                      final hasExisting =
                          widget.banner != null && widget.banner!.imageUrl.isNotEmpty;

                      return Material(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: isSaving || isProcessing
                              ? null
                              : () => context
                                  .read<BannerImageCubit>()
                                  .pickAndProcessBanner(context),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 145,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: borderColor),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: isProcessing
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : pickedFile != null
                                      ? Image.file(pickedFile, fit: BoxFit.cover)
                                      : hasExisting
                                          ? CachedImageWidget(
                                              imageUrl: widget.banner!.imageUrl,
                                              fit: BoxFit.cover,
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.add_photo_alternate_outlined,
                                                  size: 32,
                                                  color: accentColor,
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  'Select Banner Image (5:2 ratio)',
                                                  style: theme.textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: secondaryTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: isEditing ? 'Update Banner' : 'Save Banner',
                    isLoading: isSaving,
                    onPressed: isSaving ? null : () => _save(context),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onAdd;

  const _EmptyState({required this.searchQuery, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;
    final primaryTextColor = isDark
        ? AppColors.darkBodyText
        : AppColors.lightBodyText;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.gallery,
              size: 36,
              color: secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty ? 'No Banners Found' : 'No Matches',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              searchQuery.isEmpty
                  ? 'Tap the + button below to add your first banner'
                  : 'No banners match "$searchQuery"',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 20),
            if (searchQuery.isEmpty)
              AppButton(
                label: 'Add Banner',
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
