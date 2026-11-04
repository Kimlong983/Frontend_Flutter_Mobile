import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import 'splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Eager: SplashView never reads `controller`, so lazyPut would never
    // create it and the redirect would never run.
    Get.put<SplashController>(
      SplashController(authRepository: Get.find<AuthRepository>()),
    );
  }
}
