import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/cubits/student_details/student_details_cubit.dart';
import 'package:gep/cubits/student_details/student_details_state.dart';
import 'package:gep/models/enrolled_students.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

class StudentDetailsScreen extends StatelessWidget {
  final EnrolledStudent student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudentDetailsCubit()..loadShift(student.shiftId),
      child: _StudentDetailsView(student: student),
    );
  }
}

class _StudentDetailsView extends StatelessWidget {
  final EnrolledStudent student;

  const _StudentDetailsView({required this.student});

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      title: 'Student Profile',
      body: BlocBuilder<StudentDetailsCubit, StudentDetailsState>(
        builder: (context, state) {
          final shift = state.shift;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Profile Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(
                          alpha: isDark ? 0.3 : 0.6,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              theme.colorScheme.primary.withValues(alpha: 0.12),
                          child: Text(
                            student.name.isNotEmpty
                                ? student.name[0].toUpperCase()
                                : 'S',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                student.email,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  student.level.toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Personal Information Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: _buildSectionCard(
                    context: context,
                    icon: Icons.person_outline_rounded,
                    title: 'Personal Information',
                    children: [
                      _buildDetailRow(
                        context,
                        'Level',
                        student.level,
                        Icons.school_outlined,
                      ),
                      _buildDetailRow(
                        context,
                        'Gender',
                        student.gender,
                        Icons.wc_outlined,
                      ),
                      _buildDetailRow(
                        context,
                        'Date of Birth',
                        _formatDate(student.dateOfBirth),
                        Icons.cake_outlined,
                      ),
                    ],
                  ),
                ),
              ),

              // Contact Information Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: _buildSectionCard(
                    context: context,
                    icon: Icons.contact_phone_outlined,
                    title: 'Contact Information',
                    children: [
                      _buildDetailRow(
                        context,
                        "Father's Name",
                        student.fatherName,
                        Icons.badge_outlined,
                      ),
                      _buildDetailRow(
                        context,
                        'Student Contact',
                        student.contactNumber,
                        Icons.phone_outlined,
                      ),
                      _buildDetailRow(
                        context,
                        "Father's Contact",
                        student.fatherContactNumber,
                        Icons.phone_android_outlined,
                      ),
                      _buildDetailRow(
                        context,
                        'Address',
                        student.address,
                        Icons.location_on_outlined,
                      ),
                    ],
                  ),
                ),
              ),

              // Enrollment Information Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: _buildSectionCard(
                    context: context,
                    icon: Icons.assignment_outlined,
                    title: 'Enrollment & Shift',
                    children: [
                      _buildDetailRow(
                        context,
                        'Enrolled On',
                        _formatDate(student.enrollmentDate),
                        Icons.event_outlined,
                      ),
                      _buildDetailRow(
                        context,
                        'Assigned Shift',
                        shift?.name ?? 'None',
                        Icons.schedule_outlined,
                      ),
                      if (shift != null)
                        _buildDetailRow(
                          context,
                          'Shift Timing',
                          shift.timeRange,
                          Icons.access_time_rounded,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              theme.colorScheme.outline.withValues(alpha: isDark ? 0.3 : 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
