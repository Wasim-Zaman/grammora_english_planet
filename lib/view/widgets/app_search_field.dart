import 'package:material_ui/material_ui.dart';

import '../../core/constants/constants.dart';
import 'text_field_widget.dart';

/// Search field wired to a cubit's debounced search.
///
/// Shows a clear (X) suffix icon whenever [query] is non-empty and forwards
/// text changes to [onChanged]. This removes the need for a local
/// `addListener(() => setState(() {}))` just to toggle the suffix icon.
class AppSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final String labelText;
  final String? hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const AppSearchField({
    super.key,
    required this.controller,
    required this.query,
    required this.labelText,
    this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColorSecondary = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    return TextFieldWidget(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icons.search_rounded,
      suffixIcon: query.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              color: textColorSecondary,
              onPressed: () {
                controller.clear();
                onClear();
              },
            )
          : null,
      onChanged: onChanged,
    );
  }
}
