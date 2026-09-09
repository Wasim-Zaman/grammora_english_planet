import 'package:material_ui/material_ui.dart';
import 'package:toastification/toastification.dart';

class TopSnackbar {
  static void success(BuildContext context, String message) {
    toastification.show(
      context: context,
      title: Text(message),
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      animationDuration: const Duration(milliseconds: 300),
      showProgressBar: false,
      closeButton: ToastCloseButton(showType: CloseButtonShowType.onHover),
    );
  }

  static void info(BuildContext context, String message) {
    toastification.show(
      context: context,
      title: Text(message),
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      animationDuration: const Duration(milliseconds: 300),
      showProgressBar: false,
      closeButton: ToastCloseButton(showType: CloseButtonShowType.onHover),
    );
  }

  static void error(BuildContext context, String message) {
    toastification.show(
      context: context,
      title: Text(message),
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 4),
      alignment: Alignment.topCenter,
      animationDuration: const Duration(milliseconds: 300),
      showProgressBar: false,
      closeButton: ToastCloseButton(showType: CloseButtonShowType.onHover),
    );
  }
}
