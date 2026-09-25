import 'package:material_ui/material_ui.dart';

/// Outlined button for secondary actions.
///
/// Defaults to full-width, rounded (16px), with bold label.
class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool expanded;
  final double? height;
  final double borderRadius;
  final Widget? icon;
  final Color? foregroundColor;
  final Color? borderColor;

  const AppOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expanded = true,
    this.height = 50,
    this.borderRadius = 16,
    this.icon,
    this.foregroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? double.infinity : null,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          side: borderColor != null
              ? BorderSide(color: borderColor!)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 10)],
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
