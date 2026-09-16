import 'package:gep/core/constants/constants.dart';
import 'package:gep/router/app_navigation.dart';
import 'package:gep/services/analytics/analytics_service.dart';
import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';

class GridItem extends StatelessWidget {
  const GridItem({
    super.key,
    required this.title,
    required this.gradient,
    this.routeName,
    required this.lottieUrl,
    required this.fallbackIcon,
    this.onTap,
  });

  final String title;
  final Gradient gradient;
  final String? routeName;
  final String lottieUrl;
  final IconData fallbackIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        if (routeName != null) {
          final analyticsService = AnalyticsService();
          await analyticsService.logButtonClick(title);
          if (!context.mounted) return;
          AppNavigation.push(context, routeName!);
        } else if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Lottie.asset(
                  lottieUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Icon(
                    fallbackIcon,
                    size: 28,
                    color: isDark ? AppColors.darkIcon : AppColors.lightIcon,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
