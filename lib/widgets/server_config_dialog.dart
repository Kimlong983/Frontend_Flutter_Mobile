import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../data/local/token_store_local.dart';
import 'app_snackbar.dart';

/// Lets the user point the app at the backend (emulator vs. desktop vs. device).
void showServerConfigDialog({VoidCallback? onSaved}) {
  final urlController = TextEditingController(text: TokenStoreLocal.getBaseUrl());

  Get.defaultDialog(
    title: "Backend Server URL",
    titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Android emulator: 10.0.2.2. Desktop/web: localhost. Real device: your PC's LAN IP.",
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: urlController,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            labelText: "Base URL",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.dns_rounded),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            ActionChip(
              label: const Text("Emulator"),
              onPressed: () => urlController.text = "http://10.0.2.2:33033",
            ),
            ActionChip(
              label: const Text("Localhost"),
              onPressed: () => urlController.text = "http://localhost:33033",
            ),
          ],
        ),
      ],
    ),
    textConfirm: "Save",
    confirmTextColor: Colors.white,
    buttonColor: AppColors.primary,
    textCancel: "Cancel",
    onConfirm: () {
      final url = urlController.text.trim();
      final uri = Uri.tryParse(url);
      if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https')) || uri.host.isEmpty) {
        AppSnackbar.error("Invalid URL", "Enter a URL like http://10.0.2.2:33033");
        return;
      }
      TokenStoreLocal.setBaseUrl(url);
      Get.key.currentState?.pop(); // Get.back() would only dismiss an open snackbar.
      onSaved?.call();
      AppSnackbar.success("Saved", "API server set to ${TokenStoreLocal.getBaseUrl()}");
    },
  );
}
