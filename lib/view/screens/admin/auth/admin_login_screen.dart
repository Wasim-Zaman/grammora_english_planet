import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/constants.dart';
import '../../../../cubits/auth/auth_cubit.dart';
import '../../../../router/app_navigation.dart';
import '../../../../router/app_routes.dart';
import '../../../../utils/snackbars.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/text_field_widget.dart';
import 'package:material_ui/material_ui.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
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
                      Image.asset(AppIcons.gepLogo, height: 200, width: 200),
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
                        controller: authCubit.identifierController,
                        labelText: 'Email or Phone Number',
                        hintText: 'Enter your email or phone number',
                        prefixIcon: Icons.person,
                        keyboardType: TextInputType.emailAddress,
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
                            isLoading: state is AuthLoading,
                            onPressed: state is AuthLoading
                                ? null
                                : () => authCubit.loginAdmin(),
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
