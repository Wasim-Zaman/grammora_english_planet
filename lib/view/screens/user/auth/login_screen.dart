import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/constants.dart';
import '../../../../cubits/auth/auth_cubit.dart';
import '../../../../cubits/theme/theme_cubit.dart';
import '../../../../router/app_navigation.dart';
import '../../../../router/app_routes.dart';
import '../../../../utils/snackbars.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_scaffold.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess && !state.isAdmin) {
          TopSnackbar.success(context, 'Login successful');
          AppNavigation.goAndClearStack(context, AppRoutes.kDashboardRoute);
        } else if (state is AuthFailure) {
          TopSnackbar.error(context, state.errorMessage);
        }
      },
      child: AppScaffold(
        leading: const SizedBox.shrink(),
        actions: [
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              final isLightTheme = state.themeMode == ThemeMode.light;
              return IconButton(
                tooltip: 'Toggle Theme',
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: anim,
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: Icon(
                    isLightTheme
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    key: ValueKey(isLightTheme),
                  ),
                ),
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),
        ],
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 28.0,
                vertical: 20.0,
              ),
              physics: const BouncingScrollPhysics(),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, opacity, child) => Opacity(
                  opacity: opacity,
                  child: child!,
                ),
                child: TweenAnimationBuilder<Offset>(
                  tween: Tween(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, offset, child) => FractionalTranslation(
                    translation: offset,
                    child: child!,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Hero(
                        tag: 'app_logo',
                        child: Image.asset(
                          AppIcons.gepLogo,
                          height: 180,
                          width: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Welcome Back!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue with your account',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 40),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return AppButton(
                            label: 'Sign in with Google',
                            isLoading: isLoading,
                            onPressed: isLoading
                                ? null
                                : () => context
                                      .read<AuthCubit>()
                                      .signInWithGoogle(),
                            icon: Image.asset(
                              isDark
                                  ? AppIcons.signinDark
                                  : AppIcons.siginLight,
                              height: 22.0,
                              width: 22.0,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'By continuing, you agree to our Terms of Service and Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
