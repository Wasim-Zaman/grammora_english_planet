import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Navigation utility class using GoRouter
class AppNavigation {
  /// Navigate to a named route
  static void go(BuildContext context, String routeName, {Object? extra}) {
    context.goNamed(routeName, extra: extra);
  }

  /// Navigate to a path
  static void goPath(BuildContext context, String path) {
    context.go(path);
  }

  /// Navigate to a named route with query parameters
  static void goNamed(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? queryParameters,
    Object? extra,
  }) {
    if (queryParameters != null) {
      context.goNamed(
        routeName,
        queryParameters: queryParameters,
        extra: extra,
      );
    } else {
      context.goNamed(routeName, extra: extra);
    }
  }

  /// Push a named route and keep the current route in stack
  static void push(
    BuildContext context,
    String routeName, {
    Object? extra,
    Map<String, String>? queryParameters,
  }) {
    context.pushNamed(
      routeName,
      extra: extra,
      queryParameters: queryParameters ?? {},
    );
  }

  /// Push a path and keep the current route in stack
  static void pushPath(BuildContext context, String path) {
    context.push(path);
  }

  /// Push a named route with query parameters
  static void pushNamed(
    BuildContext context,
    String routeName, {
    Map<String, String>? queryParameters,
    Object? extra,
  }) {
    context.pushNamed(
      routeName,
      queryParameters: queryParameters ?? {},
      extra: extra,
    );
  }

  /// Push and replace the current route
  static void pushReplacement(
    BuildContext context,
    String routeName, {
    Object? extra,
  }) {
    context.pushReplacementNamed(routeName, extra: extra);
  }

  /// Navigate and remove all previous routes (like pushAndRemoveUntil)
  static void goAndClearStack(
    BuildContext context,
    String routeName, {
    Object? extra,
  }) {
    context.goNamed(routeName, extra: extra);
  }

  /// Go back to previous route
  static void pop(BuildContext context) {
    context.pop();
  }

  /// Go back with a result
  static void popWithResult<T>(BuildContext context, T result) {
    context.pop(result);
  }

  /// Push and wait for result
  static Future<T?> pushForResult<T>(
    BuildContext context,
    String routeName, {
    Object? extra,
  }) {
    return context.pushNamed<T>(routeName, extra: extra);
  }

  /// Check if we can pop
  static bool canPop(BuildContext context) {
    return context.canPop();
  }
}
