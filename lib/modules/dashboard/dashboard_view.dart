import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../employee/employee_controller.dart';
import '../home/home_controller.dart';
import '../product/product_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final products = Get.find<ProductController>();
    final employees = Get.find<EmployeeController>();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => Future.wait([products.fetchProducts(), employees.fetchEmployees()]),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Obx(() => _WelcomeCard(
                name: home.currentUser.value?.username ?? "User",
                role: home.currentUser.value?.roles.firstOrNull,
              )),
          const SizedBox(height: 24),
          const _SectionTitle("Overview"),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: "Products",
                  icon: Icons.inventory_2_rounded,
                  color: AppColors.primary,
                  bgColor: AppColors.primaryLight,
                  value: () => products.isLoading.value ? "…" : "${products.productList.length}",
                  onTap: () => home.changeTab(HomeController.productsTab),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _MetricCard(
                  title: "Employees",
                  icon: Icons.people_alt_rounded,
                  color: AppColors.success,
                  bgColor: AppColors.successLight,
                  value: () => employees.isLoading.value ? "…" : "${employees.employeeList.length}",
                  onTap: () => home.changeTab(HomeController.employeesTab),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const _SectionTitle("Quick Actions"),
          const SizedBox(height: 14),
          _ActionTile(
            title: "Add New Employee",
            subtitle: "Register a new employee record",
            icon: Icons.person_add_rounded,
            color: AppColors.accent,
            onTap: employees.navigateToAddEmployee,
          ),
          const SizedBox(height: 10),
          _ActionTile(
            title: "Manage Employees",
            subtitle: "View, update, or delete employees",
            icon: Icons.badge_rounded,
            color: AppColors.success,
            onTap: () => home.changeTab(HomeController.employeesTab),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            title: "Product Catalog",
            subtitle: "Browse products and check stock",
            icon: Icons.shopping_bag_rounded,
            color: AppColors.primary,
            onTap: () => home.changeTab(HomeController.productsTab),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      );
}

class _WelcomeCard extends StatelessWidget {
  final String name;
  final String? role;

  const _WelcomeCard({required this.name, this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome back,", style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis,
                ),
                if (role != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      role!,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String Function() value;
  final VoidCallback onTap;

  const _MetricCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => Text(
                    value(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  )),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
