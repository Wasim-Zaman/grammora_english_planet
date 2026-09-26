import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth/auth_admin_service.dart';
import '../../services/auth/auth_service.dart';

part 'auth_states.dart';

class AuthCubit extends Cubit<AuthState> {
  final AdminAuthService _adminAuthService;
  final AuthService _userAuthService = AuthService();
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  AuthCubit(this._adminAuthService) : super(AuthInitial());

  // User (Google) Authentication
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await _userAuthService.signInWithGoogle();
      if (user != null) {
        emit(AuthSuccess(isAdmin: false));
      } else {
        emit(AuthFailure('Google sign-in failed or was cancelled'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // Admin Authentication
  Future<void> loginAdmin() async {
    emit(AuthLoading());
    try {
      if (identifierController.text.isEmpty ||
          passwordController.text.isEmpty) {
        emit(AuthFailure('Please enter your email/phone and password.'));
        return;
      }
      bool success = await _adminAuthService.signInAdmin(
        identifierController.text.trim(),
        passwordController.text,
      );

      if (success) {
        await _adminAuthService.setAdminLoggedIn(true);
        emit(AuthSuccess(isAdmin: true));
      } else {
        emit(AuthFailure('Invalid credentials. Please try again.'));
      }
    } catch (e) {
      emit(AuthFailure('An error occurred. Please try again later.'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _adminAuthService.setAdminLoggedIn(false);
      await _userAuthService.signOut();
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> checkAdminStatus() async {
    final isAdmin = await _adminAuthService.isAdminLoggedIn();
    if (state is AuthSuccess && (state as AuthSuccess).isAdmin == isAdmin) {
      return;
    }
    emit(AuthSuccess(isAdmin: isAdmin));
  }

  Future<bool> isAdminLoggedIn() async {
    return await _adminAuthService.isAdminLoggedIn();
  }

  @override
  Future<void> close() {
    identifierController.dispose();
    passwordController.dispose();

    return super.close();
  }
}
