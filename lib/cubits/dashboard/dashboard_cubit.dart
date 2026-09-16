import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/cubits/auth/auth_cubit.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final AuthCubit _authCubit;

  DashboardCubit(this._authCubit) : super(const DashboardState());

  Future<void> init() async {
    try {
      final isAdmin = await _authCubit.isAdminLoggedIn();
      emit(DashboardState(isAdminLoggedIn: isAdmin, isLoading: false));
    } catch (_) {
      emit(const DashboardState(isAdminLoggedIn: false, isLoading: false));
    }
  }
}
