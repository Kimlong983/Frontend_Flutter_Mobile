import 'package:get/get.dart';
import '../core/services/api_service.dart';
import '../core/services/api_service_impl.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/employee_repository.dart';
import '../data/repositories/product_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services
    Get.lazyPut<ApiService>(() => ApiServiceImpl(), fenix: true);

    // Repositories (Repository Pattern)
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(apiService: Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<ProductRepository>(
      () => ProductRepositoryImpl(apiService: Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<EmployeeRepository>(
      () => EmployeeRepositoryImpl(apiService: Get.find<ApiService>()),
      fenix: true,
    );
  }
}
