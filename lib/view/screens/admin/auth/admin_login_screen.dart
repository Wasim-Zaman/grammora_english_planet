import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/auth/auth_cubit.dart';
import 'package:gep/router/app_navigation.dart';
import 'package:gep/router/app_routes.dart';
import 'package:gep/utils/snackbars.dart';
import 'package:gep/view/widgets/app_button.dart';
import 'package:gep/view/widgets/app_scaffold.dart';
import 'package:gep/view/widgets/text_field_widget.dart';
import 'package:material_ui/material_ui.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Builder(
      builder: (context) {
        final authCubit = context.read<AuthCubit>();
        return BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess && state.isAdmin) {
              TopSnackbar.success(context, 'Login successful');
              AppNavigation.goAndClearStack(
                context,
                AppRoutes.kAdminDashboardRoute,
              );
            } else if (state is AuthFailure) {
              TopSnackbar.error(context, state.errorMessage);
            }
          },
          child: AppScaffold(
            title: 'Admin Login',
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 80),
                      Image.asset(
                        isDark ? AppIcons.gepLogoDark : AppIcons.gepLogoLight,
                        height: 200,
                        width: 200,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Admin Login',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Enter your credentials to access the admin dashboard',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 50),
                      TextFieldWidget(
                        controller: authCubit.phoneController,
                        labelText: 'Phone Number',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextFieldWidget(
                        controller: authCubit.passwordController,
                        labelText: 'Password',
                        prefixIcon: Icons.lock,
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      BlocConsumer<AuthCubit, AuthState>(
                        listener: (context, state) {
                          if (state is AuthSuccess) {
                            AppNavigation.push(
                              context,
                              AppRoutes.kAdminDashboardRoute,
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is AuthFailure) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                state.errorMessage,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return AppButton(
                            label: 'Login',
                            onPressed: state is AuthLoading
                                ? null
                                : () => authCubit.loginAdmin(),
                            isLoading: state is AuthLoading,
                            backgroundColor: theme.primaryColor,
                            foregroundColor: theme.colorScheme.onPrimary,
                            borderRadius: 8,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
