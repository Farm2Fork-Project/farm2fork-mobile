import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';

class DriverAuth extends AuthController {
  @override
  Future<AuthState> build() async => const AuthState(
    status: AuthStatus.authenticated,
    user: AuthUser(
      id: 'transporter-1',
      email: 'driver@test.com',
      role: AppUserRole.transporter,
      isVerified: true,
      isActive: true,
    ),
  );
}
