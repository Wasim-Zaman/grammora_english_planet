import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../cubits/admin/admin_cubit.dart';
import '../../../../../models/about_me.dart';
import '../../../../../router/app_navigation.dart';
import '../../../../../router/app_routes.dart';
import '../../../../../utils/snackbars.dart';
import '../../../../widgets/app_scaffold.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'About Me',
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminFailure) {
            TopSnackbar.error(context, state.error);
          }
        },
        builder: (context, state) {
          return StreamBuilder<AboutMe>(
            stream: context.read<AdminCubit>().getAboutMeStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Failed to load details',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              }

              final aboutMe = snapshot.data ?? AboutMe();
              final theme = Theme.of(context);
              final colors = theme.colorScheme;

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  // Minimalist Hero Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 44,
                            backgroundColor: colors.surfaceContainerHigh,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: aboutMe.profileImageUrl ?? '',
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                                placeholder: (_, _) =>
                                    const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                errorWidget: (_, _, _) => Icon(
                                  Icons.person_rounded,
                                  size: 40,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sana Ullah',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Instructor',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action Group Card
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _Tile(
                          icon: Icons.map_outlined,
                          title: 'Institute Location',
                          subtitle: 'Tap to view on Google Maps',
                          onTap: () => _launchMaps(
                            context,
                            aboutMe.latitude,
                            aboutMe.longitude,
                          ),
                        ),
                        Divider(
                          height: 1,
                          indent: 56,
                          color: colors.outlineVariant.withValues(alpha: 0.2),
                        ),
                        _Tile(
                          icon: Icons.description_outlined,
                          title: 'Resume / CV',
                          subtitle: aboutMe.resumeUrl != null
                              ? 'Tap to open document'
                              : 'No document uploaded',
                          onTap: aboutMe.resumeUrl != null
                              ? () => AppNavigation.push(
                                  context,
                                  AppRoutes.kFullScreenResumeRoute,
                                  extra: aboutMe.resumeUrl!,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _launchMaps(
    BuildContext context,
    double latitude,
    double longitude,
  ) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      TopSnackbar.error(context, 'Could not open the map');
    }
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final enabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          icon,
          size: 22,
          color: enabled
              ? colors.primary
              : colors.onSurface.withValues(alpha: 0.3),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: enabled
                ? colors.onSurface
                : colors.onSurface.withValues(alpha: 0.4),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: colors.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
