import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../data/local/token_store_local.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/server_config_dialog.dart';
import '../dashboard/dashboard_view.dart';
import '../employee/employee_view.dart';
import '../product/product_view.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static const _titles = ["Dashboard", "Products", "Employees", "Profile"];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardView(),
      const ProductView(),
      const EmployeeView(),
      const _ProfileTab(),
    ];

    return Obx(() {
      final index = controller.currentIndex.value;

      return Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(
                _titles[index],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                  tooltip: "Sign Out",
                  onPressed: controller.confirmLogout,
                ),
              ],
            ),
            body: IndexedStack(index: index, children: pages),
            bottomNavigationBar: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: controller.changeTab,
              backgroundColor: Colors.white,
              indicatorColor: AppColors.primaryLight,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
                  label: "Dashboard",
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2_rounded, color: AppColors.primary),
                  label: "Products",
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline_rounded),
                  selectedIcon: Icon(Icons.people_alt_rounded, color: AppColors.primary),
                  label: "Employees",
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
                  label: "Profile",
                ),
              ],
            ),
          ),
          if (controller.isLoggingOut.value)
            const ColoredBox(
              color: Colors.black38,
              child: LoadingWidget(message: "Signing out..."),
            ),
        ],
      );
    });
  }
}

class _ProfileTab extends GetView<HomeController> {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser.value;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _card(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 40),
              ),
              const SizedBox(height: 14),
              Text(
                user?.username ?? "User",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              if (user?.email != null) ...[
                const SizedBox(height: 4),
                Text(user!.email!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
              if (user != null && user.roles.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: user.roles
                      .map((role) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              role,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.cloud_sync_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "API Server",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Obx(
                () => Text(
                  controller.baseUrl.value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => showServerConfigDialog(
                    onSaved: () => controller.baseUrl.value = TokenStoreLocal.getBaseUrl(),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 16, color: AppColors.primary),
                  label: const Text("Change Server URL", style: TextStyle(color: AppColors.primary)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: controller.confirmLogout,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
            label: const Text(
              "Sign Out",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      );
}
