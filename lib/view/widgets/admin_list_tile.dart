import 'package:gep/core/constants/constants.dart';
import 'package:material_ui/material_ui.dart';

/// A modern, reusable list tile for admin screens.
///
/// Provides a consistent card-style appearance with optional leading icon
/// (inside a themed rounded container), title, subtitle, trailing action
/// buttons, and tap handling.
class AdminListTile extends StatelessWidget {
  /// An optional icon displayed inside a 40×40 rounded container.
  /// Use this for simple icon leads.
  final IconData? leadingIcon;

  /// Background color of the leading icon container.
  /// Defaults to `theme.colorScheme.primary.withValues(alpha: 0.1)`.
  final Color? leadingBackgroundColor;

  /// Color of the leading icon itself.
  /// Defaults to `theme.colorScheme.primary`.
  final Color? leadingIconColor;

  /// A custom leading widget (e.g. `CircleAvatar`).
  /// If provided, [leadingIcon] is ignored.
  final Widget? leading;

  /// Primary title text.
  final String title;

  /// Optional subtitle text.
  final String? subtitle;

  /// List of trailing widgets, typically `IconButton`s.
  final List<Widget>? trailingActions;

  /// Callback when the tile is tapped.
  final VoidCallback? onTap;

  /// Padding inside the tile.
  final EdgeInsetsGeometry contentPadding;

  /// Corner radius of the tile.
  final double borderRadius;

  const AdminListTile({
    super.key,
    this.leadingIcon,
    this.leadingBackgroundColor,
    this.leadingIconColor,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailingActions,
    this.onTap,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 4,
    ),
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColorSecondary = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    Widget? effectiveLeading;
    if (leading != null) {
      effectiveLeading = leading;
    } else if (leadingIcon != null) {
      effectiveLeading = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: leadingBackgroundColor ??
              theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          leadingIcon,
          color: leadingIconColor ?? theme.colorScheme.primary,
          size: 20,
        ),
      );
    }

    return Material(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: borderColor),
      ),
      child: ListTile(
        contentPadding: contentPadding,
        leading: effectiveLeading,
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColorSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: trailingActions != null && trailingActions!.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: trailingActions!,
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
