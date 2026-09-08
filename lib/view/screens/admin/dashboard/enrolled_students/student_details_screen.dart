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
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Student Details',
      body: BlocBuilder<StudentDetailsCubit, StudentDetailsState>(
        builder: (context, state) {
          final shift = state.shift;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Student Information',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            student.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                          const Divider(),
                          _buildDetailRow('Email', student.email),
                          _buildDetailRow('Level', student.level),
                          _buildDetailRow(
                            'Date of Birth',
                            _formatDate(student.dateOfBirth),
                          ),
                          _buildDetailRow('Gender', student.gender),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('Father\'s Name', student.fatherName),
                          _buildDetailRow(
                            'Student Contact',
                            student.contactNumber,
                          ),
                          _buildDetailRow(
                            'Father\'s Contact',
                            student.fatherContactNumber,
                          ),
                          _buildDetailRow('Address', student.address),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enrollment Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            'Enrollment Date',
                            _formatDate(student.enrollmentDate),
                          ),
                          _buildDetailRow(
                            'Assigned Shift',
                            shift?.name ?? 'None',
                          ),
                          if (shift != null)
                            _buildDetailRow(
                              'Shift Time',
                              shift.timeRange,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
