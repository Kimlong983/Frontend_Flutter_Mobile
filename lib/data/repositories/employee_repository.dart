import '../../constants/constant_uri.dart';
import '../../core/services/api_service.dart';
import '../../models/employee/employee_model.dart';

abstract class EmployeeRepository {
  Future<List<EmployeeModel>> getEmployees();
  Future<EmployeeModel> createEmployee(EmployeeModel employee);
  Future<EmployeeModel> updateEmployee(int id, EmployeeModel employee);
  Future<void> deleteEmployee(int id);
}

class EmployeeRepositoryImpl implements EmployeeRepository {
  final ApiService apiService;

  EmployeeRepositoryImpl({required this.apiService});

  @override
  Future<List<EmployeeModel>> getEmployees() async {
    final response = await apiService.get(ConstantUri.employees);
    if (response is! List) return [];
    return response.map((e) => EmployeeModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<EmployeeModel> createEmployee(EmployeeModel employee) async {
    final response = await apiService.post(ConstantUri.employees, body: employee.toRequestJson());
    return response is Map ? EmployeeModel.fromJson(Map<String, dynamic>.from(response)) : employee;
  }

  @override
  Future<EmployeeModel> updateEmployee(int id, EmployeeModel employee) async {
    final response = await apiService.put(ConstantUri.employeeById(id), body: employee.toRequestJson());
    return response is Map ? EmployeeModel.fromJson(Map<String, dynamic>.from(response)) : employee;
  }

  @override
  Future<void> deleteEmployee(int id) async {
    await apiService.delete(ConstantUri.employeeById(id));
  }
}
