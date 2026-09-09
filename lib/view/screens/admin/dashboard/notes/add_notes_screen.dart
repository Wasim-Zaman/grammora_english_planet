import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/admin/admin_cubit.dart';
import 'package:gep/cubits/note_upload/note_upload_cubit.dart';
import 'package:gep/cubits/note_upload/note_upload_state.dart';
import 'package:gep/models/note.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/app_button.dart';
import 'package:gep/view/widgets/app_dialog.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/note_card.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:gep/view/widgets/text_field_widget.dart';
import 'package:material_ui/material_ui.dart';

class AddNotesScreen extends StatefulWidget {
  final String category;

  const AddNotesScreen({super.key, required this.category});

  @override
  State<AddNotesScreen> createState() => _AddNotesScreenState();
}

class _AddNotesScreenState extends State<AddNotesScreen> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
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

    if (widget.category.trim().isEmpty) {
      return const AppScaffold(
        title: 'Add Note',
        body: Center(
          child: Text('No category specified. Please select a category first.'),
        ),
      );
    }

    return BlocProvider(
      create: (_) => NoteUploadCubit(),
      child: AppScaffold(
        title: widget.category,
        body: BlocConsumer<AdminCubit, AdminState>(
          listener: (context, state) {
            if (state is AdminSuccess) {
              TopSnackbar.success(context, state.message);
              _titleController.clear();
            } else if (state is AdminFailure) {
              TopSnackbar.error(context, 'Error: ${state.error}');
            }
          },
          builder: (context, adminState) {
            final isLoading = adminState is AdminLoading;

            return BlocBuilder<NoteUploadCubit, NoteUploadState>(
              builder: (context, uploadState) {
                return RefreshIndicator(
                  onRefresh: () async {},
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      // Upload Section Card
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.all(
                            AppConstants.defaultPadding,
                          ),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardColor,
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
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.upload_file_rounded,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'UPLOAD PDF NOTE',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                      color: textColorSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // File Dropzone / Selected File Card
                              if (uploadState.selectedFile == null)
                                Material(
                                  color: isDark
                                      ? AppColors.darkNeutral.withValues(alpha: 0.5)
                                      : AppColors.lightNeutral,
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: isLoading
                                        ? null
                                        : () => context
                                            .read<NoteUploadCubit>()
                                            .pickFile(),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 24,
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.3),
                                          style: BorderStyle.solid,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.cloud_upload_rounded,
                                              color: theme.colorScheme.primary,
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Tap to select PDF document',
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            'Supports valid PDF files up to 25MB',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: textColorSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444)
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFEF4444)
                                          .withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEF4444)
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.picture_as_pdf_rounded,
                                          color: Color(0xFFEF4444),
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              uploadState.fileName ??
                                                  'Document.pdf',
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              uploadState.fileSize ?? '',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: textColorSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                        ),
                                        onPressed: () => context
                                            .read<NoteUploadCubit>()
                                            .clearFile(),
                                        tooltip: 'Remove file',
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 14),
                              TextFieldWidget(
                                controller: _titleController,
                                labelText: 'Note Title',
                                hintText: 'Enter a descriptive title',
                                prefixIcon: Icons.title_rounded,
                              ),
                              const SizedBox(height: 14),
                              AppButton(
                                label: isLoading
                                    ? 'Uploading…'
                                    : 'Upload Document',
                                icon: const Icon(Icons.upload_rounded),
                                onPressed: isLoading
                                    ? null
                                    : () => _handleUpload(context, uploadState),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Section Title
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppConstants.defaultPadding + 4,
                            8,
                            AppConstants.defaultPadding + 4,
                            12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.folder_copy_rounded,
                                size: 16,
                                color: textColorSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'DOCUMENTS IN THIS CATEGORY',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: textColorSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Stream of Notes
                      StreamBuilder<List<Note>>(
                        stream: context
                            .read<AdminCubit>()
                            .getNotesStream(widget.category),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.defaultPadding,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: PlaceholderWidgets.listPlaceholder(),
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return SliverFillRemaining(
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
                                      'Failed to load notes',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          final notes = snapshot.data ?? [];
                          if (notes.isEmpty) {
                            return SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.folder_off_rounded,
                                      size: 40,
                                      color: textColorSecondary,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No Notes Found',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Upload a PDF document above to add the first note',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: textColorSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              AppConstants.defaultPadding,
                              0,
                              AppConstants.defaultPadding,
                              24,
                            ),
                            sliver: SliverList(
                              delegate:
                                  SliverChildBuilderDelegate((context, index) {
                                final note = notes[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: NoteCard(
                                    note: note,
                                    showDelete: true,
                                    onDelete: () =>
                                        _confirmDeleteNote(context, note),
                                  ),
                                );
                              }, childCount: notes.length),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _handleUpload(BuildContext context, NoteUploadState uploadState) {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      TopSnackbar.info(context, 'Please enter a note title first');
      return;
    }
    if (uploadState.selectedFile == null) {
      TopSnackbar.info(context, 'Please select a PDF document first');
      return;
    }

    context.read<AdminCubit>().uploadNote(
          widget.category.trim(),
          title,
          uploadState.selectedFile!,
        );
    context.read<NoteUploadCubit>().clearFile();
  }

  Future<void> _confirmDeleteNote(BuildContext context, Note note) async {
    final adminCubit = context.read<AdminCubit>();
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Delete Document',
      message: 'Are you sure you want to delete "${note.title}"?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true) {
      adminCubit.deleteNote(
        widget.category,
        note.id,
        note.url,
      );
    }
  }
}
