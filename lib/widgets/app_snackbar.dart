import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(String title, String message) =>
      _show(title, message, AppColors.success, Icons.check_circle_outline);

  static void error(String title, String message) =>
      _show(title, message, AppColors.danger, Icons.error_outline, seconds: 4);

  static void _show(String title, String message, Color color, IconData icon, {int seconds = 2}) {
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: Duration(seconds: seconds),
    );
  }
}
