import 'package:material_ui/material_ui.dart';
import 'package:gep/view/widgets/app_scaffold.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Terms and Conditions',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Last updated: November 01, 2024',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              theme,
              '1. Acceptance of Terms',
              'By accessing and using the SELC application, you accept and agree to be bound by these terms and conditions. These terms apply to all users, including students, administrators, and visitors.',
            ),
            _buildSection(
              theme,
              '2. User Accounts',
              'Users may access the app through Google Sign-In. You are responsible for maintaining the confidentiality of your account and all activities under your account. Admin accounts have additional privileges and responsibilities.',
            ),
            _buildSection(
              theme,
              '3. Educational Content',
              'All educational content, including notes, playlists, course outlines, and updates, are provided for educational purposes. Users may access and view content but may not redistribute or use it for commercial purposes.',
            ),
            _buildSection(
              theme,
              '4. Student Information',
              'Personal information collected includes name, contact details, and educational records. This information is handled in accordance with our Privacy Policy and used solely for educational and administrative purposes.',
            ),
            _buildSection(
              theme,
              '5. Location Services',
              'The app uses location services to display institute location. Users can access Google Maps integration for navigation purposes. Location data is used only for displaying institute location.',
            ),
            _buildSection(
              theme,
              '6. Third-Party Services',
              'The app integrates with Google services (Sign-In, Maps), YouTube, and Firebase. Usage of these services is subject to their respective terms and conditions.',
            ),
            _buildSection(
              theme,
              '7. Content Guidelines',
              'Users must not upload, share, or create inappropriate, illegal, or harmful content. Administrators reserve the right to remove content or restrict access.',
            ),
            _buildSection(
              theme,
              '8. Updates and Changes',
              'We may update these terms at any time. Continued use of the app after changes constitutes acceptance of the new terms.',
            ),
            _buildSection(
              theme,
              '9. Termination',
              'We reserve the right to terminate or suspend access to the app for violations of these terms or for any other reason.',
            ),
            _buildSection(
              theme,
              '10. Contact',
              'For questions about these terms, please contact the institute administration.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
