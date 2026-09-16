import 'package:firebase_analytics/observer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:toastification/toastification.dart';

import 'core/themes/themes.dart';
import 'cubits/theme/theme_cubit.dart';
import 'router/app_router.dart';
import 'view/widgets/app_wrapper.dart';

class MyApp extends StatelessWidget {
  final FirebaseAnalyticsObserver observer;
  const MyApp({super.key, required this.observer});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return ToastificationWrapper(
          child: AppWrapper(
            child: MaterialApp.router(
              title: 'Gramora English Planet',
              debugShowCheckedModeBanner: false,
              theme: AppThemes.lightTheme,
              darkTheme: AppThemes.darkTheme,
              themeMode: state.themeMode,
              routerConfig: AppRouter.router,
            ),
          ),
        );
      },
    );
  }
}
