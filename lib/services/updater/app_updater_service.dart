import 'package:flutter/foundation.dart';
import 'package:upgrader/upgrader.dart';

/// Centralized service to manage automatic app update alerts for both
/// Google Play Store (Android) and Apple App Store (iOS).
class AppUpdaterService {
  AppUpdaterService._internal();

  static final AppUpdaterService instance = AppUpdaterService._internal();

  /// Shared [Upgrader] configuration.
  /// 
  /// - [durationUntilAlertAgain]: Remind the user again after 1 day if dismissed.
  /// - [debugDisplayAlways]: Set to false so alerts only trigger
  ///   when an actual new version is released on the respective store.
  /// - [debugLogging]: Logs upgrader debug info in development.
  final Upgrader upgrader = Upgrader(
    durationUntilAlertAgain: const Duration(days: 1),
    debugDisplayAlways: false,
    debugLogging: kDebugMode,
    // Optional: Specify a minimum version if you ever want to force an update:
    // minAppVersion: '2.1.0',
  );
}
