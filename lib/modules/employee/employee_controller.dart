import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/employee_repository.dart';
import '../../models/employee/employee_model.dart';
import '../../routes/app_route_name.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/confirm_dialog.dart';

class EmployeeController extends GetxController {
  final EmployeeRepository employeeRepository;

  EmployeeController({required this.employeeRepository});

  final employeeList = <EmployeeModel>[].obs;
  final filteredEmployeeList = <EmployeeModel>[].obs;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final deletingId = Rxn<int>();

  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchEmployees() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      employeeList.assignAll(await employeeRepository.getEmployees());
      _applySearch();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applySearch();
  }

  void clearSearch() {
    searchController.clear();
    onSearchChanged('');
  }

  void _applySearch() {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      filteredEmployeeList.assignAll(employeeList);
      return;
    }
    bool has(String? s) => s?.toLowerCase().contains(q) ?? false;
    filteredEmployeeList.assignAll(employeeList.where((e) =>
        has(e.fullName) ||
        has(e.employeeCode) ||
        has(e.email) ||
        has(e.phoneNumber) ||
        has(e.position) ||
        has(e.department)));
  }

  Future<void> navigateToAddEmployee() => _openForm(null);

  Future<void> navigateToEditEmployee(EmployeeModel employee) => _openForm(employee);

  Future<void> _openForm(EmployeeModel? employee) async {
    final saved = await Get.toNamed(AppRouteName.employeeForm, arguments: employee);
    if (saved == true) await fetchEmployees();
  }

  Future<void> confirmDelete(EmployeeModel employee) async {
    if (employee.id == null || deletingId.value != null) return;

    final confirmed = await showConfirmDialog(
      title: "Delete Employee",
      message: "Delete ${employee.fullName} (${employee.employeeCode})? This action cannot be undone.",
      confirmText: "Delete",
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed) return;

    deletingId.value = employee.id;
    try {
      await employeeRepository.deleteEmployee(employee.id!);
      employeeList.removeWhere((e) => e.id == employee.id);
      _applySearch();
      AppSnackbar.success("Deleted", "${employee.fullName} has been removed.");
    } catch (e) {
      AppSnackbar.error("Delete Failed", e.toString());
    } finally {
      deletingId.value = null;
    }
  }
}
