import 'dart:io';

import 'package:gep/utils/file_picker_utils.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/admin/admin_cubit.dart';
import 'package:gep/models/about_me.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/app_button.dart';
import 'package:gep/view/widgets/app_scaffold.dart';

import 'package:gep/view/widgets/text_field_widget.dart';
import 'package:image_picker/image_picker.dart';

class ManageAboutMeScreen extends StatefulWidget {
  const ManageAboutMeScreen({super.key});

  @override
  State<ManageAboutMeScreen> createState() => _ManageAboutMeScreenState();
}

class _ManageAboutMeScreenState extends State<ManageAboutMeScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _profileImageFile;
  File? _resumeFile;
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _youtubeChannelController =
      TextEditingController();

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
      title: 'Manage About Me',
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminSuccess) {
            TopSnackbar.success(context, state.message);
          } else if (state is AdminFailure) {
            TopSnackbar.error(context, state.error);
          }
        },
        builder: (context, state) {
          final isLoading = state is AdminLoading;

          return StreamBuilder<AboutMe>(
            stream: context.read<AdminCubit>().getAboutMeStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
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
                        'Failed to load data',
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
              final aboutMe = snapshot.data ?? AboutMe();
              _latitudeController.text = aboutMe.latitude.toString();
              _longitudeController.text = aboutMe.longitude.toString();
              _youtubeChannelController.text = aboutMe.youtubeChannelLink;

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                children: [
                  // Profile Image Section
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
                              Icons.image_rounded,
                              size: 18,
                              color: isDark
                                  ? AppColors.darkIcon
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'PROFILE PICTURE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: textColorSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: _ProfileImage(
                            file: _profileImageFile,
                            url: aboutMe.profileImageUrl,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: AppButton(
                            label: 'Pick Image',
                            icon: const Icon(Icons.add_photo_alternate_rounded),
                            expanded: false,
                            onPressed: isLoading ? null : _pickImage,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details Form
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_rounded,
                                size: 18,
                                color: isDark
                                    ? AppColors.darkIcon
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'INFORMATION',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: textColorSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFieldWidget(
                            controller: _latitudeController,
                            labelText: 'Latitude',
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.location_on_rounded,
                          ),
                          const SizedBox(height: 16),
                          TextFieldWidget(
                            controller: _longitudeController,
                            labelText: 'Longitude',
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 16),
                          TextFieldWidget(
                            controller: _youtubeChannelController,
                            labelText: 'YouTube Channel Link',
                            prefixIcon: Icons.video_library_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Resume Section
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
                              Icons.description_rounded,
                              size: 18,
                              color: isDark
                                  ? AppColors.darkIcon
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'RESUME',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: textColorSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_resumeFile != null || aboutMe.resumeUrl != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.insert_drive_file_rounded,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _resumeFile != null
                                        ? 'New resume selected'
                                        : 'Resume uploaded',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (_resumeFile != null)
                                  IconButton(
                                    icon: Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: textColorSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _resumeFile = null;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'Pick Resume',
                          icon: const Icon(Icons.upload_file_rounded),
                          expanded: false,
                          onPressed: isLoading ? null : _pickResume,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Save Changes',
                    onPressed: isLoading ? null : () => _saveAboutMe(context),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickResume() async {
    final file = await FilePickerUtils.pickPdfFile();
    if (file != null) {
      setState(() {
        _resumeFile = file;
      });
    }
  }

  void _saveAboutMe(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final aboutMe = AboutMe(
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        youtubeChannelLink: _youtubeChannelController.text,
      );
      context.read<AdminCubit>().updateAboutMe(
            aboutMe,
            profileImage: _profileImageFile,
            resume: _resumeFile,
          );
    }
  }
}

class _ProfileImage extends StatelessWidget {
  final File? file;
  final String? url;

  const _ProfileImage({this.file, this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (file != null) {
      return ClipOval(
        child: Image.file(
          file!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    }

    if (url != null && url!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black12,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (_, _, _) {
            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black12,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: Colors.grey),
            );
          },
        ),
      );
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black12,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.add_photo_alternate_rounded, color: Colors.grey),
    );
  }
}
