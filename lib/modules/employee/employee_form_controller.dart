import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../data/repositories/employee_repository.dart';
import '../../models/employee/employee_model.dart';
import '../../widgets/app_snackbar.dart';

/// Add / edit form. Validation mirrors the EmployeeReq schema in Swagger.
class EmployeeFormController extends GetxController {
  final EmployeeRepository employeeRepository;

  EmployeeFormController({required this.employeeRepository});

  static const genders = {"MALE": "Male", "FEMALE": "Female", "OTHER": "Other"};
  static final _phonePattern = RegExp(r'^\+?[0-9 ]{8,15}$');

  final formKey = GlobalKey<FormState>();

  final employeeCodeController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final positionController = TextEditingController();
  final departmentController = TextEditingController();
  final salaryController = TextEditingController();
  final addressController = TextEditingController();
  final photoUrlController = TextEditingController();

  final gender = Rxn<String>();
  final dateOfBirth = Rxn<DateTime>();
  final hireDate = Rxn<DateTime>();
  final isActive = true.obs;
  final isSubmitting = false.obs;

  EmployeeModel? _editing;
  bool get isEditMode => _editing != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is EmployeeModel) _fill(args);
  }

  @override
  void onClose() {
    for (final c in [
      employeeCodeController,
      firstNameController,
      lastNameController,
      emailController,
      phoneNumberController,
      positionController,
      departmentController,
      salaryController,
      addressController,
      photoUrlController,
    ]) {
      c.dispose();
    }
    super.onClose();
  }

  void _fill(EmployeeModel e) {
    _editing = e;
    employeeCodeController.text = e.employeeCode;
    firstNameController.text = e.firstName;
    lastNameController.text = e.lastName;
    emailController.text = e.email;
    phoneNumberController.text = e.phoneNumber;
    positionController.text = e.position ?? "";
    departmentController.text = e.department ?? "";
    salaryController.text = e.salary == null ? "" : _formatSalary(e.salary!);
    addressController.text = e.address ?? "";
    photoUrlController.text = e.photoUrl ?? "";
    gender.value = genders.containsKey(e.gender) ? e.gender : null;
    dateOfBirth.value = e.dateOfBirth;
    hireDate.value = e.hireDate;
    isActive.value = e.isActive;
  }

  String _formatSalary(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  // ---- Validators ----

  String? Function(String?) requiredMax(String field, int max) => (value) {
        final v = value?.trim() ?? "";
        if (v.isEmpty) return "$field is required";
        if (v.length > max) return "$field must be at most $max characters";
        return null;
      };

  String? Function(String?) optionalMax(String field, int max) =>
      (value) => (value?.trim().length ?? 0) > max ? "$field must be at most $max characters" : null;

  String? validateEmail(String? value) {
    final v = value?.trim() ?? "";
    if (v.isEmpty) return "Email is required";
    if (!GetUtils.isEmail(v)) return "Enter a valid email address";
    return null;
  }

  String? validatePhone(String? value) {
    final v = value?.trim() ?? "";
    if (v.isEmpty) return "Phone number is required";
    if (!_phonePattern.hasMatch(v)) return "8–15 digits, may start with +";
    return null;
  }

  String? validateSalary(String? value) {
    final v = value?.trim() ?? "";
    if (v.isEmpty) return null;
    final n = double.tryParse(v);
    if (n == null) return "Enter a valid number";
    if (n < 0) return "Salary cannot be negative";
    return null;
  }

  String? validatePhotoUrl(String? value) {
    final v = value?.trim() ?? "";
    if (v.isEmpty) return null;
    final uri = Uri.tryParse(v);
    return (uri == null || !uri.hasScheme || uri.host.isEmpty) ? "Enter a valid URL (https://...)" : null;
  }

  // ---- Date pickers ----

  Future<void> pickDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final picked = await _pickDate(
      context,
      initial: dateOfBirth.value ?? DateTime(now.year - 25),
      first: DateTime(1940),
      last: now,
    );
    if (picked != null) dateOfBirth.value = picked;
  }

  Future<void> pickHireDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await _pickDate(
      context,
      initial: hireDate.value ?? now,
      first: DateTime(1980),
      last: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null) hireDate.value = picked;
  }

  Future<DateTime?> _pickDate(
    BuildContext context, {
    required DateTime initial,
    required DateTime first,
    required DateTime last,
  }) {
    final clamped = initial.isBefore(first) ? first : (initial.isAfter(last) ? last : initial);
    return showDatePicker(
      context: context,
      initialDate: clamped,
      firstDate: first,
      lastDate: last,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
  }

  // ---- Submit ----

  Future<void> submit() async {
    if (isSubmitting.value) return;
    FocusManager.instance.primaryFocus?.unfocus();

    if (!formKey.currentState!.validate()) {
      AppSnackbar.error("Check the form", "Please fix the highlighted fields.");
      return;
    }
    final dob = dateOfBirth.value;
    final hired = hireDate.value;
    if (dob != null && hired != null && hired.isBefore(dob)) {
      AppSnackbar.error("Check the form", "Hire date cannot be before date of birth.");
      return;
    }

    final employee = EmployeeModel(
      id: _editing?.id,
      employeeCode: employeeCodeController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      gender: gender.value,
      dateOfBirth: dob,
      email: emailController.text.trim(),
      phoneNumber: phoneNumberController.text.trim(),
      position: positionController.text,
      department: departmentController.text,
      salary: double.tryParse(salaryController.text.trim()),
      hireDate: hired,
      address: addressController.text,
      photoUrl: photoUrlController.text,
      status: isActive.value ? "ACT" : "INA",
    );

    isSubmitting.value = true;
    try {
      if (isEditMode) {
        await employeeRepository.updateEmployee(_editing!.id!, employee);
      } else {
        await employeeRepository.createEmployee(employee);
      }
      // Pop the route directly: Get.back() would only dismiss an open snackbar.
      Get.key.currentState?.pop(true);
      AppSnackbar.success(
        isEditMode ? "Employee Updated" : "Employee Created",
        "${employee.fullName} was saved successfully.",
      );
    } catch (e) {
      AppSnackbar.error("Save Failed", e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }
}
