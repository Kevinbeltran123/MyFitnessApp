import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

enum AppSnackBarTone { success, error, warning, info }

class AppSnackBar {
  const AppSnackBar._();

  static void showSuccess(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(context, message, AppSnackBarTone.success,
        actionLabel: actionLabel, onAction: onAction);
  }

  static void showError(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(context, message, AppSnackBarTone.error,
        actionLabel: actionLabel, onAction: onAction);
  }

  static void showWarning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(context, message, AppSnackBarTone.warning,
        actionLabel: actionLabel, onAction: onAction);
  }

  static void showInfo(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(context, message, AppSnackBarTone.info,
        actionLabel: actionLabel, onAction: onAction);
  }

  static SnackBar successSnack(String message,
      {String? actionLabel, VoidCallback? onAction}) {
    return _buildSnackBar(
      message: message,
      tone: AppSnackBarTone.success,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static SnackBar errorSnack(String message,
      {String? actionLabel, VoidCallback? onAction}) {
    return _buildSnackBar(
      message: message,
      tone: AppSnackBarTone.error,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static SnackBar warningSnack(String message,
      {String? actionLabel, VoidCallback? onAction}) {
    return _buildSnackBar(
      message: message,
      tone: AppSnackBarTone.warning,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static SnackBar infoSnack(String message,
      {String? actionLabel, VoidCallback? onAction}) {
    return _buildSnackBar(
      message: message,
      tone: AppSnackBarTone.info,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void _show(
    BuildContext context,
    String message,
    AppSnackBarTone tone, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(
        message: message,
        tone: tone,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }

  static SnackBar _buildSnackBar({
    required String message,
    required AppSnackBarTone tone,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final Color background = switch (tone) {
      AppSnackBarTone.success => AppColors.success,
      AppSnackBarTone.error => AppColors.error,
      AppSnackBarTone.warning => AppColors.warning,
      AppSnackBarTone.info => AppColors.info,
    };
    final SnackBarAction? action = (actionLabel != null && onAction != null)
        ? SnackBarAction(label: actionLabel, onPressed: onAction)
        : null;
    return SnackBar(
      content: Text(message),
      backgroundColor: background,
      behavior: SnackBarBehavior.floating,
      action: action,
    );
  }
}
