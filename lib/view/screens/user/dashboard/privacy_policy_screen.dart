import 'package:flutter_animate/flutter_animate.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:material_ui/material_ui.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const List<_Section> _sections = [
    _Section(
      '1. Introduction',
      'Gramora English Planet ("GEP", "we", "us", or "our") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, store, and safeguard your information when you use the GEP mobile application.',
    ),
    _Section(
      '2. Information We Collect',
      'We collect information you provide when signing in via Google, including your name, email address, and profile photo. We may also collect enrollment details, attendance records, and device information necessary for app functionality.',
    ),
    _Section(
      '3. How We Use Your Information',
      'Your information is used to authenticate you, provide access to educational content, track attendance, manage admissions, communicate updates, and improve the app experience. We do not sell your personal information to third parties.',
    ),
    _Section(
      '4. Google Sign-In',
      'We use Google Sign-In to authenticate users securely. When you sign in, Google shares your basic profile information with us in accordance with Google\'s privacy policy and your account settings.',
    ),
    _Section(
      '5. Location Data',
      'The app may access your device location to display the institute location and provide navigation through Google Maps. Location data is used only when needed and is not stored on our servers.',
    ),
    _Section(
      '6. Third-Party Services',
      'We use trusted third-party services including Firebase (authentication, analytics, and cloud storage), Supabase (database), Google Maps, and YouTube. These services may collect data according to their own privacy policies.',
    ),
    _Section(
      '7. Data Security',
      'We implement reasonable security measures to protect your data from unauthorized access, alteration, or disclosure. However, no method of electronic storage is completely secure, and we cannot guarantee absolute security.',
    ),
    _Section(
      '8. Data Retention',
      'We retain your information for as long as your account is active or as needed to provide services, comply with legal obligations, resolve disputes, and enforce our agreements.',
    ),
    _Section(
      '9. Children\'s Privacy',
      'GEP is intended for learners of all ages. If you are under 13, please use the app under parental or guardian supervision. We do not knowingly collect personal information from children without appropriate consent.',
    ),
    _Section(
      '10. Your Rights',
      'You may access, update, or request deletion of your personal information by contacting institute administration. You can also revoke app access through your Google account settings at any time.',
    ),
    _Section(
      '11. Changes to This Policy',
      'We may update this Privacy Policy from time to time. Any changes will be posted in the app with an updated effective date. Continued use of the app constitutes acceptance of the revised policy.',
    ),
    _Section(
      '12. Contact Us',
      'If you have any questions about this Privacy Policy or how we handle your data, please contact Gramora English Planet administration through the About Me section or official institute channels.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Privacy Policy',
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
      decoration: const BoxDecoration(
        gradient: AppGradients.privacy,
        borderRadius: BorderRadius.all(Radius.circular(24)),
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
              Icons.shield_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Privacy Policy',
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
