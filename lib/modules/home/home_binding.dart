import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/employee_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../employee/employee_controller.dart';
import '../product/product_controller.dart';
import 'home_controller.dart';

/// Home hosts every tab, so it registers the controllers for all of them.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(authRepository: Get.find<AuthRepository>()),
    );
    Get.lazyPut<ProductController>(
      () => ProductController(productRepository: Get.find<ProductRepository>()),
    );
    Get.lazyPut<EmployeeController>(
      () => EmployeeController(employeeRepository: Get.find<EmployeeRepository>()),
    );
  }
}
