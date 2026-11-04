import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_route_name.dart';
import '../../widgets/app_snackbar.dart';

class LoginController extends GetxController {
  final AuthRepository authRepository;

  LoginController({required this.authRepository});

  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  String? validateUsername(String? value) =>
      (value == null || value.trim().isEmpty) ? "Please enter your username" : null;

  String? validatePassword(String? value) =>
      (value == null || value.isEmpty) ? "Please enter your password" : null;

  Future<void> login() async {
    if (isLoading.value || !formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();

    isLoading.value = true;
    try {
      final username = usernameController.text.trim();
      final user = await authRepository.login(username, passwordController.text);
      Get.offAllNamed(AppRouteName.home);
      AppSnackbar.success("Welcome", "Signed in as ${user?.username ?? username}");
    } catch (e) {
      AppSnackbar.error("Login Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
