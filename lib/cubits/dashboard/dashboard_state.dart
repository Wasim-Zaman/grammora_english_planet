part of 'dashboard_cubit.dart';

class DashboardState extends Equatable {
  final bool isAdminLoggedIn;
  final bool isLoading;

  const DashboardState({
    this.isAdminLoggedIn = false,
    this.isLoading = true,
  });

  DashboardState copyWith({
    bool? isAdminLoggedIn,
    bool? isLoading,
  }) {
    return DashboardState(
      isAdminLoggedIn: isAdminLoggedIn ?? this.isAdminLoggedIn,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [isAdminLoggedIn, isLoading];
}
