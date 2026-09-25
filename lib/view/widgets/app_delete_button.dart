import 'package:material_ui/material_ui.dart';

import '../../core/constants/constants.dart';

/// Destructive button for delete / danger actions.
///
/// Defaults to red background, white text, full-width.
class AppDeleteButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool expanded;
  final double? height;
  final double borderRadius;
  final bool isLoading;

  const AppDeleteButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expanded = true,
    this.height = 50,
    this.borderRadius = 16,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
