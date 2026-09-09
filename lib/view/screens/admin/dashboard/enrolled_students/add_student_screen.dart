// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:gep/models/enrolled_students.dart';
import 'package:gep/services/enrolled_students/enrolled_students_services.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:gep/view/widgets/text_field_widget.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/app_button.dart';
import 'package:gep/cubits/student_form/student_form_cubit.dart';
import 'package:gep/cubits/student_form/student_form_state.dart';

class AddStudentScreen extends StatefulWidget {
  final EnrolledStudentsServices enrolledStudentsServices;

  const AddStudentScreen({super.key, required this.enrolledStudentsServices});

  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _levelController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _fatherContactNumberController = TextEditingController();
  final _addressController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _fatherNameFocus = FocusNode();
  final _levelFocus = FocusNode();
  final _contactNumberFocus = FocusNode();
  final _fatherContactNumberFocus = FocusNode();
  final _addressFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudentFormCubit()..loadShifts(),
      child: BlocConsumer<StudentFormCubit, StudentFormState>(
        listener: (context, state) {
          if (state.error != null) {
            TopSnackbar.error(context, "Failed to add student: ${state.error}");
          }
        },
        builder: (context, state) {
          return AppScaffold(
            title: 'Add New Student',
            body: state.isLoading
                ? PlaceholderWidgets.addStudentScreenPlaceholder()
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFieldWidget(
                            controller: _nameController,
                            labelText: 'Name',
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter a name' : null,
                            focusNode: _nameFocus,
                            onFieldSubmitted: (_) =>
                                FocusScope.of(context).requestFocus(_emailFocus),
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          TextFieldWidget(
                            controller: _emailController,
                            labelText: 'Email (Optional)',
                            focusNode: _emailFocus,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_fatherNameFocus),
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          TextFieldWidget(
                            controller: _fatherNameController,
                            labelText: 'Father\'s Name',
                            validator: (value) => value!.isEmpty
                                ? 'Please enter father\'s name'
                                : null,
                            focusNode: _fatherNameFocus,
                            onFieldSubmitted: (_) =>
                                FocusScope.of(context).requestFocus(_levelFocus),
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          TextFieldWidget(
                            controller: _levelController,
                            labelText: 'Level',
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter a level' : null,
                            focusNode: _levelFocus,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_contactNumberFocus),
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          TextFieldWidget(
                            controller: _contactNumberController,
                            labelText: 'Contact Number (Optional)',
                            focusNode: _contactNumberFocus,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_fatherContactNumberFocus),
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          TextFieldWidget(
                            controller: _fatherContactNumberController,
                            labelText: 'Father\'s Contact Number (Optional)',
                            focusNode: _fatherContactNumberFocus,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_addressFocus),
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          TextFieldWidget(
                            controller: _addressController,
                            labelText: 'Address',
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter an address' : null,
                            focusNode: _addressFocus,
                            onFieldSubmitted: (_) => _addStudent(context, state),
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          ListTile(
                            title: const Text('Date of Birth'),
                            subtitle: Text(DateFormat('yyyy-MM-dd')
                                .format(state.dateOfBirth)),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: state.dateOfBirth,
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                context
                                    .read<StudentFormCubit>()
                                    .setDateOfBirth(picked);
                              }
                            },
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          DropdownButtonFormField<String>(
                            initialValue: state.gender,
                            decoration: const InputDecoration(labelText: 'Gender'),
                            items: ['Male', 'Female', 'Other']
                                .map((label) => DropdownMenuItem(
                                      value: label,
                                      child: Text(label),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                context
                                    .read<StudentFormCubit>()
                                    .setGender(value);
                              }
                            },
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          DropdownButtonFormField<String?>(
                            initialValue: state.selectedShiftId,
                            decoration: const InputDecoration(
                              labelText: 'Assigned Shift',
                              hintText: 'Select a shift (optional)',
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('None'),
                              ),
                              ...state.shifts.map((shift) => DropdownMenuItem(
                                    value: shift.id,
                                    child: Text(shift.name),
                                  )),
                            ],
                            onChanged: (value) {
                              context
                                  .read<StudentFormCubit>()
                                  .setSelectedShiftId(value);
                            },
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          ListTile(
                            title: const Text('Enrollment Date'),
                            subtitle: Text(DateFormat('yyyy-MM-dd')
                                .format(state.enrollmentDate)),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: state.enrollmentDate,
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                context
                                    .read<StudentFormCubit>()
                                    .setEnrollmentDate(picked);
                              }
                            },
                          ),
                          const SizedBox(height: AppConstants.defaultPadding * 2),
                          AppButton(
                            onPressed: () => _addStudent(context, state),
                            label: 'Add Student',
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  void _addStudent(BuildContext context, StudentFormState state) async {
    if (_formKey.currentState!.validate()) {
      final newStudent = EnrolledStudent(
        id: '',
        name: _nameController.text,
        email: _emailController.text,
        fatherName: _fatherNameController.text,
        level: _levelController.text,
        contactNumber: _contactNumberController.text,
        fatherContactNumber: _fatherContactNumberController.text,
        address: _addressController.text,
        dateOfBirth: state.dateOfBirth,
        gender: state.gender,
        enrollmentDate: state.enrollmentDate,
        shiftId: state.selectedShiftId,
      );

      final success = await context.read<StudentFormCubit>().saveStudent(
            service: widget.enrolledStudentsServices,
            student: newStudent,
            isEdit: false,
          );

      if (success && mounted) {
        TopSnackbar.success(context, "Student added successfully");
        Navigator.pop(context, true);
      }
    } else {
      TopSnackbar.error(context, "Please fill all fields");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _fatherNameController.dispose();
    _levelController.dispose();
    _contactNumberController.dispose();
    _fatherContactNumberController.dispose();
    _addressController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _fatherNameFocus.dispose();
    _levelFocus.dispose();
    _contactNumberFocus.dispose();
    _fatherContactNumberFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }
}
