abstract class ApiService {
  Future<dynamic> get(String url, {Map<String, dynamic>? queryParams, bool requiresAuth = true});
  Future<dynamic> post(String url, {dynamic body, bool requiresAuth = true});
  Future<dynamic> put(String url, {dynamic body, bool requiresAuth = true});
  Future<dynamic> delete(String url, {bool requiresAuth = true});
}
