import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/services/auth/auth_admin_service.dart';
import 'package:gep/services/auth/auth_service.dart';

part 'auth_states.dart';

class AuthCubit extends Cubit<AuthState> {
  final AdminAuthService _adminAuthService;
  final AuthService _userAuthService = AuthService();
  final TextEditingController phoneController = TextEditingController();
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
      if (phoneController.text.isEmpty || passwordController.text.isEmpty) {
        emit(AuthFailure('Please enter your phone number and password.'));
        return;
      }
      bool success = await _adminAuthService.signInAdmin(
        phoneController.text.trim(),
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
    emit(AuthSuccess(isAdmin: isAdmin));
  }

  Future<bool> isAdminLoggedIn() async {
    return await _adminAuthService.isAdminLoggedIn();
  }

  @override
  Future<void> close() {
    phoneController.dispose();
    passwordController.dispose();

    return super.close();
  }
}
