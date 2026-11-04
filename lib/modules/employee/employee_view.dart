import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../models/employee/employee_model.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/search_bar_field.dart';
import 'employee_controller.dart';

class EmployeeView extends GetView<EmployeeController> {
  const EmployeeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: SearchBarField(
              controller: controller.searchController,
              query: controller.searchQuery,
              hint: "Search by name, code, email, department...",
              onChanged: controller.onSearchChanged,
              onClear: controller.clearSearch,
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.employeeList.isEmpty) {
                return const LoadingWidget(message: "Loading employees...");
              }
              if (controller.errorMessage.isNotEmpty && controller.employeeList.isEmpty) {
                return ErrorStateWidget(message: controller.errorMessage.value, onRetry: controller.fetchEmployees);
              }
              if (controller.filteredEmployeeList.isEmpty) {
                final searching = controller.searchQuery.value.isNotEmpty;
                return EmptyStateWidget(
                  title: "No Employees Found",
                  subtitle: searching
                      ? "No employees match '${controller.searchQuery.value}'"
                      : "Start building your team by adding an employee.",
                  icon: Icons.people_outline_rounded,
                  actionText: searching ? "Clear Search" : "Add Employee",
                  onAction: searching ? controller.clearSearch : controller.navigateToAddEmployee,
                );
              }

              // Read here (not in itemBuilder) so Obx tracks it.
              final deletingId = controller.deletingId.value;
              return RefreshIndicator(
                onRefresh: controller.fetchEmployees,
                color: AppColors.primary,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  itemCount: controller.filteredEmployeeList.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final employee = controller.filteredEmployeeList[index];
                    return _EmployeeCard(
                      employee: employee,
                      isDeleting: deletingId == employee.id,
                      onEdit: () => controller.navigateToEditEmployee(employee),
                      onDelete: () => controller.confirmDelete(employee),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-employee',
        onPressed: controller.navigateToAddEmployee,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text("Add Employee", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;
  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EmployeeCard({
    required this.employee,
    required this.isDeleting,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDeleting ? 0.5 : 1,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Avatar(employee: employee),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (employee.jobTitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            employee.jobTitle,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _Tag(text: employee.employeeCode, bg: AppColors.primaryLight, fg: AppColors.primary),
                      const SizedBox(height: 4),
                      employee.isActive
                          ? const _Tag(text: "Active", bg: AppColors.successLight, fg: AppColors.success)
                          : const _Tag(text: "Inactive", bg: AppColors.divider, fg: AppColors.textSecondary),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 12),
              _ContactRow(icon: Icons.email_outlined, text: employee.email),
              const SizedBox(height: 4),
              _ContactRow(icon: Icons.phone_outlined, text: employee.phoneNumber),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: isDeleting ? null : onEdit,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                    label: const Text(
                      "Edit",
                      style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: isDeleting ? null : onDelete,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      side: const BorderSide(color: AppColors.dangerLight),
                      backgroundColor: AppColors.dangerLight,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: isDeleting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.danger),
                          )
                        : const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger),
                    label: Text(
                      isDeleting ? "Deleting..." : "Delete",
                      style: const TextStyle(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final EmployeeModel employee;

  const _Avatar({required this.employee});

  static const _palette = [
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _palette[employee.fullName.hashCode.abs() % _palette.length];
    return CircleAvatar(
      radius: 24,
      backgroundColor: color,
      foregroundImage: employee.hasPhoto ? NetworkImage(employee.photoUrl!) : null,
      onForegroundImageError: employee.hasPhoto ? (_, _) {} : null,
      child: Text(
        employee.initials,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _Tag({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
      );
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
}
