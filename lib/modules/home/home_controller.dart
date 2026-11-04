import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/local/token_store_local.dart';
import '../../data/repositories/auth_repository.dart';
import '../../models/auth/user_model.dart';
import '../../routes/app_route_name.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/confirm_dialog.dart';

class HomeController extends GetxController {
  final AuthRepository authRepository;

  HomeController({required this.authRepository});

  static const int dashboardTab = 0;
  static const int productsTab = 1;
  static const int employeesTab = 2;
  static const int profileTab = 3;

  final currentIndex = dashboardTab.obs;
  final currentUser = Rxn<UserModel>();
  final isLoggingOut = false.obs;
  final baseUrl = TokenStoreLocal.getBaseUrl().obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = authRepository.getCurrentUser();
  }

  void changeTab(int index) => currentIndex.value = index;

  Future<void> confirmLogout() async {
    final confirmed = await showConfirmDialog(
      title: "Sign Out",
      message: "Are you sure you want to end your current session?",
      confirmText: "Log Out",
      icon: Icons.logout_rounded,
    );
    if (!confirmed) return;

    isLoggingOut.value = true;
    await authRepository.logout();
    isLoggingOut.value = false;
    Get.offAllNamed(AppRouteName.login);
    AppSnackbar.success("Signed Out", "You have been signed out.");
  }
}
