import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/admin/admin_cubit.dart';
import 'package:gep/models/note.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/app_button.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/note_card.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:gep/view/widgets/text_field_widget.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../utils/file_picker_utils.dart';

class AddNotesScreen extends StatelessWidget {
  final String category;

  AddNotesScreen({super.key, required this.category});

  final TextEditingController _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColorSecondary = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return AppScaffold(
      title: 'Add Note to $category',
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: BlocConsumer<AdminCubit, AdminState>(
          listener: (context, state) {
            if (state is AdminSuccess) {
              TopSnackbar.success(context, state.message);
              _titleController.clear();
            } else if (state is AdminFailure) {
              TopSnackbar.error(context, 'Error: ${state.error}');
            }
          },
          builder: (context, state) {
            final isLoading = state is AdminLoading;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.upload_file_rounded,
                            size: 18,
                            color: isDark
                                ? AppColors.darkIcon
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'UPLOAD NOTE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: textColorSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFieldWidget(
                        controller: _titleController,
                        labelText: 'Note Title',
                        prefixIcon: Icons.title_rounded,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Select and Upload PDF',
                        icon: const Icon(Icons.attach_file_rounded),
                        onPressed: isLoading
                            ? null
                            : () => _pickAndUploadFile(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder_copy_rounded,
                        size: 14,
                        color: textColorSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'NOTES IN THIS CATEGORY',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: textColorSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: AppConstants.defaultPadding),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                Expanded(
                  child: StreamBuilder<List<Note>>(
                    stream: context.read<AdminCubit>().getNotesStream(category),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return PlaceholderWidgets.listPlaceholder();
                      }
                      if (snapshot.hasError) {
                        return Center(
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
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${snapshot.error}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: textColorSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_off_rounded,
                                size: 36,
                                color: textColorSecondary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No Notes Found',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Upload a PDF above to get started',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: textColorSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: snapshot.data!.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return Dismissible(
                            key: Key(snapshot.data![index].id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) {
                              _deleteNote(context, snapshot.data![index]);
                            },
                            child: NoteCard(note: snapshot.data![index]),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickAndUploadFile(BuildContext context) async {
    final file = await FilePickerUtils.pickPdfFile();
    if (file != null && context.mounted) {
      context.read<AdminCubit>().uploadNote(
        category,
        _titleController.text,
        file,
      );
    }
  }

  void _deleteNote(BuildContext context, Note note) {
    context.read<AdminCubit>().deleteNote(category, note.id, note.url);
  }
}
