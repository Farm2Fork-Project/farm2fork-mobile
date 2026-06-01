import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';

enum AuthStatus {
  guest,
  loadingSession,
  authenticated,
  unauthenticated,
  sessionExpired,
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.isActive,
  });

  final String id;
  final String email;
  final AppUserRole role;
  final bool isVerified;
  final bool isActive;

  static AppUserRole roleFromBackend(String value) {
    return switch (value) {
      'farmer' => AppUserRole.farmer,
      'buyer' => AppUserRole.buyer,
      'transporter' => AppUserRole.transporter,
      'financial_partner' => AppUserRole.financialPartner,
      'admin' => AppUserRole.admin,
      _ => throw ArgumentError.value(value, 'role', 'Unsupported user role'),
    };
  }

  static String roleToBackend(AppUserRole role) {
    return switch (role) {
      AppUserRole.farmer => 'farmer',
      AppUserRole.buyer => 'buyer',
      AppUserRole.transporter => 'transporter',
      AppUserRole.financialPartner => 'financial_partner',
      AppUserRole.admin => 'admin',
    };
  }
}

class AuthState {
  const AuthState({this.status = AuthStatus.guest, this.user});

  final AuthStatus status;
  final AuthUser? user;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  // true for guest, unauthenticated, and sessionExpired — all map to guest shell
  bool get isGuest => !isAuthenticated && status != AuthStatus.loadingSession;
  AppUserRole? get role => user?.role;
}
