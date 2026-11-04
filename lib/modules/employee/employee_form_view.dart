import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../models/employee/employee_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'employee_form_controller.dart';

class EmployeeFormView extends GetView<EmployeeFormController> {
  const EmployeeFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          c.isEditMode ? "Edit Employee" : "Add Employee",
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: c.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _Section(
                title: "Personal Information",
                icon: Icons.person_outline_rounded,
                children: [
                  CustomTextField(
                    controller: c.employeeCodeController,
                    label: "Employee Code *",
                    hint: "EMP001",
                    prefixIcon: Icons.badge_outlined,
                    maxLength: 50,
                    textInputAction: TextInputAction.next,
                    validator: c.requiredMax("Employee code", 50),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: c.firstNameController,
                          label: "First Name *",
                          hint: "John",
                          maxLength: 100,
                          textInputAction: TextInputAction.next,
                          validator: c.requiredMax("First name", 100),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: c.lastNameController,
                          label: "Last Name *",
                          hint: "Doe",
                          maxLength: 100,
                          textInputAction: TextInputAction.next,
                          validator: c.requiredMax("Last name", 100),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const _Label("Gender"),
                  Obx(
                    () => Row(
                      children: [
                        for (final entry in EmployeeFormController.genders.entries) ...[
                          if (entry.key != "MALE") const SizedBox(width: 8),
                          Expanded(
                            child: _ChoiceTile(
                              label: entry.value,
                              selected: c.gender.value == entry.key,
                              // Tap again to clear (gender is optional).
                              onTap: () => c.gender.value = c.gender.value == entry.key ? null : entry.key,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _Label("Date of Birth"),
                  Obx(() => _DateField(
                        value: c.dateOfBirth.value,
                        placeholder: "Select date of birth",
                        onTap: () => c.pickDateOfBirth(context),
                        onClear: () => c.dateOfBirth.value = null,
                      )),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: "Contact",
                icon: Icons.contact_phone_outlined,
                children: [
                  CustomTextField(
                    controller: c.emailController,
                    label: "Email *",
                    hint: "employee@example.com",
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    textInputAction: TextInputAction.next,
                    validator: c.validateEmail,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: c.phoneNumberController,
                    label: "Phone Number *",
                    hint: "+855 12 345 678",
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    textInputAction: TextInputAction.next,
                    validator: c.validatePhone,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: c.addressController,
                    label: "Address",
                    hint: "Phnom Penh, Cambodia",
                    prefixIcon: Icons.home_outlined,
                    maxLines: 2,
                    maxLength: 255,
                    validator: c.optionalMax("Address", 255),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: "Job",
                icon: Icons.business_center_outlined,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: c.positionController,
                          label: "Position",
                          hint: "Developer",
                          maxLength: 100,
                          textInputAction: TextInputAction.next,
                          validator: c.optionalMax("Position", 100),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: c.departmentController,
                          label: "Department",
                          hint: "IT",
                          maxLength: 100,
                          textInputAction: TextInputAction.next,
                          validator: c.optionalMax("Department", 100),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: c.salaryController,
                    label: "Salary",
                    hint: "1200",
                    prefixIcon: Icons.attach_money_rounded,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    validator: c.validateSalary,
                  ),
                  const SizedBox(height: 14),
                  const _Label("Hire Date"),
                  Obx(() => _DateField(
                        value: c.hireDate.value,
                        placeholder: "Select hire date",
                        onTap: () => c.pickHireDate(context),
                        onClear: () => c.hireDate.value = null,
                      )),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: c.photoUrlController,
                    label: "Photo URL",
                    hint: "https://...",
                    prefixIcon: Icons.image_outlined,
                    keyboardType: TextInputType.url,
                    validator: c.validatePhotoUrl,
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "Active",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        c.isActive.value ? "Employee is currently active" : "Employee is inactive",
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      value: c.isActive.value,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) => c.isActive.value = v,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Obx(
                  () => CustomButton(
                    text: c.isEditMode ? "Save Changes" : "Create Employee",
                    icon: c.isEditMode ? Icons.save_rounded : Icons.check_rounded,
                    isLoading: c.isSubmitting.value,
                    onPressed: c.submit,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _Section({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      );
}

class _ChoiceTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceTile({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.8 : 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime? value;
  final String placeholder;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateField({required this.value, required this.placeholder, required this.onTap, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.only(left: 16),
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1.2),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                EmployeeModel.formatDate(value) ?? placeholder,
                style: TextStyle(fontSize: 15, color: value != null ? AppColors.textPrimary : AppColors.textMuted),
              ),
            ),
            if (value != null)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                tooltip: "Clear",
                onPressed: onClear,
              ),
          ],
        ),
      ),
    );
  }
}
