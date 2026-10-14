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
    this.fullName,
    this.avatarUrl,
    this.phone,
  });

  final String id;
  final String email;
  final AppUserRole role;
  final bool isVerified;
  final bool isActive;

  /// The person's own name, when they have given one.
  final String? fullName;

  /// Cloudinary delivery URL (256px square) built by the backend.
  final String? avatarUrl;
  final String? phone;

  /// What to call this person in the UI: their name, else the part of the
  /// email before the `@`.
  String get displayName {
    final name = fullName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }

  AuthUser copyWith({
    String? fullName,
    String? avatarUrl,
    String? phone,
    bool clearAvatar = false,
  }) {
    return AuthUser(
      id: id,
      email: email,
      role: role,
      isVerified: isVerified,
      isActive: isActive,
      fullName: fullName ?? this.fullName,
      avatarUrl: clearAvatar ? null : (avatarUrl ?? this.avatarUrl),
      phone: phone ?? this.phone,
    );
  }

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
