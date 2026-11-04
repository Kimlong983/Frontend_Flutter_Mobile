import '../data/local/token_store_local.dart';

/// Endpoints of the "Employee & Product API" (see /swagger-ui/index.html).
class ConstantUri {
  ConstantUri._();

  static String get baseUri => TokenStoreLocal.getBaseUrl();

  // Auth
  static String get login => "$baseUri/api/auth/login";
  static String get refreshToken => "$baseUri/api/auth/refresh";
  static String get logout => "$baseUri/api/auth/logout";

  // Products
  static String get products => "$baseUri/api/products";

  // Employees
  static String get employees => "$baseUri/api/employees";
  static String employeeById(int id) => "$baseUri/api/employees/$id";
}
