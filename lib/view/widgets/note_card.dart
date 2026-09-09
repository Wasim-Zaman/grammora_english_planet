import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/constants.dart';
import '../../models/note.dart';
import '../../router/app_navigation.dart';
import '../../router/app_routes.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onDelete;
  final bool showDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.onDelete,
    this.showDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final secondaryText = isDark
        ? AppColors.darkBodyTextSecondary
        : AppColors.lightBodyTextSecondary;

    final formattedDate = DateFormat('MMM d, yyyy').format(note.timestamp);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _viewPdf(context),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // PDF Thumbnail Icon Container
                Container(
                  width: 52,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Color(0xFFEF4444),
                        size: 26,
                      ),
                      Positioned(
                        bottom: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PDF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Note Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title.isNotEmpty ? note.title : 'Untitled Document',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: secondaryText,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Actions: Delete or Open Button
                if (showDelete && onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    color: AppColors.error.withValues(alpha: 0.85),
                    onPressed: onDelete,
                    tooltip: 'Delete Note',
                  )
                else
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  void _viewPdf(BuildContext context) {
    AppNavigation.push(
      context,
      AppRoutes.kPdfViewerRoute,
      extra: {'pdfUrl': note.url, 'title': note.title},
      queryParameters: {'pdfUrl': note.url, 'title': note.title},
    );
  }
}
