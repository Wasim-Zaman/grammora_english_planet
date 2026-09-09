import 'package:gep/core/constants/constants.dart';
import 'package:material_ui/material_ui.dart';

/// Modern, consistent text field used throughout the app.
///
/// Defaults to a filled style with rounded corners (16px), comfortable
/// vertical padding, and theme-aware borders. Works well in forms,
/// bottom sheets, and inline creation cards.
class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final int? maxLines;
  final FocusNode? focusNode;
  final Function(String)? onFieldSubmitted;
  final bool enabled;
  final bool readOnly;

  const TextFieldWidget({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.focusNode,
    this.onFieldSubmitted,
    this.enabled = true,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fillColor = isDark ? AppColors.darkNeutral : AppColors.lightNeutral;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final iconColor = isDark ? AppColors.darkIcon : AppColors.primary;

    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(color: borderColor),
    );

    return TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      maxLines: obscureText ? 1 : maxLines,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: isDark
              ? AppColors.darkBodyTextSecondary
              : AppColors.lightBodyTextSecondary,
          fontSize: 14,
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: isDark
              ? AppColors.darkBodyTextSecondary.withValues(alpha: 0.6)
              : AppColors.lightBodyTextSecondary.withValues(alpha: 0.6),
          fontSize: 14,
        ),
        floatingLabelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        filled: true,
        fillColor: fillColor,
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 14, right: 8),
                child: Icon(prefixIcon, size: 20, color: iconColor),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        contentPadding: EdgeInsets.only(
          left: prefixIcon != null ? 4 : 16,
          right: suffixIcon != null ? 4 : 16,
          top: 14,
          bottom: 14,
        ),
        border: baseBorder,
        enabledBorder: baseBorder,
        disabledBorder: baseBorder.copyWith(
          borderSide: BorderSide(color: borderColor.withValues(alpha: 0.4)),
        ),
        focusedBorder: baseBorder.copyWith(
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        errorBorder: baseBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: baseBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}
