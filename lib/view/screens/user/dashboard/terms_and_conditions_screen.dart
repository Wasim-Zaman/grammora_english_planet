import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/constants.dart';
import '../../../widgets/app_scaffold.dart';
import 'package:material_ui/material_ui.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  static const List<_Section> _sections = [
    _Section(
      '1. Acceptance of Terms',
      'By downloading, installing, or using the GEP (Gramora English Planet) application, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use the app.',
    ),
    _Section(
      '2. About GEP',
      'GEP is an English learning platform developed for Gramora English Planet. The app provides educational content, course outlines, notes, admissions information, attendance tracking, and institute updates for enrolled students and prospective learners.',
    ),
    _Section(
      '3. User Accounts',
      'You may sign in using Google Sign-In. You are responsible for maintaining the confidentiality of your account and for all activities that occur under your account. Admin accounts have additional management privileges and responsibilities.',
    ),
    _Section(
      '4. Educational Content',
      'All content, including notes, playlists, course outlines, and updates, is provided for educational purposes only. Users may view content for personal learning but may not redistribute, reproduce, or use it for commercial purposes without written permission.',
    ),
    _Section(
      '5. Student Information',
      'Personal information such as name, contact details, attendance records, and enrollment data may be collected and handled in accordance with our Privacy Policy. This information is used solely for educational and administrative purposes.',
    ),
    _Section(
      '6. Location Services',
      'The app may use location services to display the institute location and enable navigation through Google Maps. Location data is used only for these purposes and is not stored or tracked beyond what is necessary.',
    ),
    _Section(
      '7. Attendance and QR Code Scanning',
      'Students may scan QR codes to mark attendance. Any attempt to manipulate, spoof, or falsify attendance records is strictly prohibited and may result in account suspension.',
    ),
    _Section(
      '8. Third-Party Services',
      'The app integrates with third-party services including Google Sign-In, Google Maps, YouTube, Firebase, and Supabase. Your use of these services is subject to their respective terms and privacy policies.',
    ),
    _Section(
      '9. User Conduct',
      'Users must not upload, share, or create inappropriate, illegal, harmful, or offensive content. Administrators reserve the right to remove content, restrict access, or terminate accounts for violations.',
    ),
    _Section(
      '10. Updates to Terms',
      'We may update these Terms and Conditions at any time. Continued use of the app after changes constitutes acceptance of the revised terms. Please review this page periodically.',
    ),
    _Section(
      '11. Termination',
      'We reserve the right to suspend or terminate access to the app for violations of these terms, fraudulent activity, or any other reason deemed necessary to protect the integrity of the platform.',
    ),
    _Section(
      '12. Contact Us',
      'For questions or concerns about these Terms and Conditions, please contact Gramora English Planet administration through the About Me section or institute contact channels.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Terms and Conditions',
      safeAreaBottom: false,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          const SliverToBoxAdapter(
            child: _HeaderCard(),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _SectionTile(
                  section: _sections[index],
                  index: index,
                ),
                childCount: _sections.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _Section {
  const _Section(this.title, this.content);

  final String title;
  final String content;
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        8,
        AppConstants.defaultPadding,
        12,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.terms,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Terms and Conditions',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Last updated: September 14, 2026',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.section,
    required this.index,
  });

  final _Section section;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            section.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (80 + index * 50).ms)
        .slideY(begin: 0.08, end: 0);
  }
}
