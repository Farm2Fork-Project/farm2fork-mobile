abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double pagePadding = 16;
}

abstract final class AppRadius {
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double pill = 999;
}

abstract final class AppElevation {
  static const double cardBlur = 18;
  static const double cardOffset = 6;
}

abstract final class AppDurations {
  /// Lightweight, frequent confirmations (added to cart, item removed)
  /// that shouldn't linger and block the next interaction.
  static const Duration quickConfirmation = Duration(milliseconds: 1500);

  /// Messages the user needs a real moment to read (form success,
  /// order results, session/auth notices). Matches SnackBar's own
  /// default, made explicit so every call site agrees on it.
  static const Duration standardMessage = Duration(seconds: 4);
}
