import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_states.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const _themeKey = 'app_theme_mode';

  ThemeCubit([ThemeMode initial = ThemeMode.system])
      : super(ThemeState(initial));

  static Future<ThemeMode> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeKey);
    return ThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  void toggleTheme() {
    final newMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _persistAndEmit(newMode);
  }

  void setTheme(ThemeMode themeMode) {
    if (state.themeMode == themeMode) return;
    _persistAndEmit(themeMode);
  }

  void _persistAndEmit(ThemeMode themeMode) {
    emit(ThemeState(themeMode));
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString(_themeKey, themeMode.name),
    );
  }
}
