import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({super.key, required this.pdfUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    if (pdfUrl.trim().isEmpty) {
      return AppScaffold(
        title: title,
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'This document is unavailable — its link is missing or invalid.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return AppScaffold(
      title: title,
      body: SfPdfViewer.network(
        pdfUrl,
        enableDoubleTapZooming: true,
        interactionMode: PdfInteractionMode.pan,
      ),
    );
  }
}
