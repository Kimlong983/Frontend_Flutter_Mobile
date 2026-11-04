import '../../constants/constant_uri.dart';
import '../../core/services/api_service.dart';
import '../../core/services/api_service_impl.dart';
import '../../models/auth/login_request.dart';
import '../../models/auth/login_response.dart';
import '../../models/auth/user_model.dart';
import '../local/token_store_local.dart';

abstract class AuthRepository {
  /// Logs in and stores the JWT pair. Throws [ApiException] on failure.
  Future<UserModel?> login(String username, String password);
  Future<void> logout();
  bool isLoggedIn();
  UserModel? getCurrentUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;

  AuthRepositoryImpl({required this.apiService});

  @override
  Future<UserModel?> login(String username, String password) async {
    final response = await apiService.post(
      ConstantUri.login,
      body: LoginRequest(username: username, password: password).toJson(),
      requiresAuth: false,
    );

    if (response is! Map) {
      throw ApiException("Unexpected response from server.");
    }
    final jwt = LoginResponse.fromJson(Map<String, dynamic>.from(response));
    if (jwt.accessToken.isEmpty) {
      throw ApiException("Login failed: no access token returned.");
    }

    TokenStoreLocal.setAccessToken(jwt.accessToken);
    if (jwt.refreshToken != null) TokenStoreLocal.setRefreshToken(jwt.refreshToken!);
    if (jwt.user != null) TokenStoreLocal.setUser(jwt.user!.toJson());
    return jwt.user;
  }

  @override
  Future<void> logout() async {
    try {
      // Revokes the current access token and the refresh tokens server-side.
      await apiService.post(ConstantUri.logout);
    } catch (_) {
      // Local sign-out still happens even if the server is unreachable.
    } finally {
      TokenStoreLocal.clear();
    }
  }

  @override
  bool isLoggedIn() => TokenStoreLocal.isLoggedIn();

  @override
  UserModel? getCurrentUser() {
    final map = TokenStoreLocal.getUser();
    return map == null ? null : UserModel.fromJson(map);
  }
}
