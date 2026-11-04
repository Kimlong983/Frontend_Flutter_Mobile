import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_route_name.dart';

class SplashController extends GetxController {
  final AuthRepository authRepository;

  SplashController({required this.authRepository});

  @override
  void onReady() {
    super.onReady();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    Get.offAllNamed(authRepository.isLoggedIn() ? AppRouteName.home : AppRouteName.login);
  }
}
