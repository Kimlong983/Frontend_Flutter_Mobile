import 'package:get/get.dart';
import '../modules/employee/employee_form_binding.dart';
import '../modules/employee/employee_form_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import 'app_route_name.dart';

class AppRoute {
  AppRoute._();

  static List<GetPage> getAllRoutes() => [
        GetPage(
          name: AppRouteName.splash,
          page: () => const SplashView(),
          binding: SplashBinding(),
        ),
        GetPage(
          name: AppRouteName.login,
          page: () => const LoginView(),
          binding: LoginBinding(),
        ),
        // Home hosts the Dashboard, Products, Employees and Profile tabs.
        GetPage(
          name: AppRouteName.home,
          page: () => const HomeView(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: AppRouteName.employeeForm,
          page: () => const EmployeeFormView(),
          binding: EmployeeFormBinding(),
        ),
      ];
}
