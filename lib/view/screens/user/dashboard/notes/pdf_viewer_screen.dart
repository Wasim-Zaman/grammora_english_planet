import 'package:gep/core/constants/constants.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({super.key, required this.pdfUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (pdfUrl.trim().isEmpty) {
      return AppScaffold(
        title: title.isNotEmpty ? title : 'Document Viewer',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 14),
                Text(
                  'Document Unavailable',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'The document link is missing or no longer exists.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkBodyTextSecondary
                        : AppColors.lightBodyTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AppScaffold(
      title: title.isNotEmpty ? title : 'Document Viewer',
      body: SfPdfViewer.network(
        pdfUrl,
        enableDoubleTapZooming: true,
        interactionMode: PdfInteractionMode.pan,
        pageLayoutMode: PdfPageLayoutMode.continuous,
        canShowScrollHead: true,
        canShowScrollStatus: true,
      ),
    );
  }
}
