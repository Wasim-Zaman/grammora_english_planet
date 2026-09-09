import 'package:material_ui/material_ui.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:gep/view/widgets/app_scaffold.dart';

class FullScreenResumeScreen extends StatelessWidget {
  final String resumeUrl;

  const FullScreenResumeScreen({super.key, required this.resumeUrl});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Resume',
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      body: SfPdfViewer.network(
        resumeUrl,
        enableDoubleTapZooming: true,
      ),
    );
  }
}
