import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/onboarding_session.dart';
import 'package:farm2fork_mobile/features/auth/presentation/utils/onboarding_support.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_form_widgets.dart';

/// Compact sign-in: brand, Google, email + password, then "Create account" and
/// guest browsing as quieter paths. Everything sits in one scrollable column
/// anchored to the top, so opening the keyboard never moves the layout.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _googleBusy = false;
  String? _message;
  AuthNoticeKind _messageKind = AuthNoticeKind.error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _showMessage(
    String? message, [
    AuthNoticeKind kind = AuthNoticeKind.error,
  ]) {
    setState(() {
      _message = message;
      _messageKind = kind;
    });
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    await _handleOutcome(
      () => ref
          .read(authControllerProvider.notifier)
          .signInWithEmail(email: email, password: _passwordController.text),
      onboardingEmail: email,
    );
  }

  Future<void> _submitGoogle() async {
    setState(() => _googleBusy = true);
    try {
      await _handleOutcome(
        () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
      );
    } finally {
      if (mounted) setState(() => _googleBusy = false);
    }
  }

  /// A returning user signed in; a new identity is routed into onboarding.
  Future<void> _handleOutcome(
    Future<FirebaseSignInOutcome> Function() run, {
    String? onboardingEmail,
  }) async {
    _showMessage(null);
    try {
      final outcome = await run();
      if (!mounted) return;
      if (outcome is FirebaseVerificationRequired) {
        ref
            .read(onboardingSessionProvider.notifier)
            .start(
              OnboardingSession(
                email: outcome.email,
                method: OnboardingMethod.google,
              ),
            );
        context.push('/auth/verify');
        return;
      }
      if (outcome is FirebaseOnboardingRequired) {
        ref
            .read(onboardingSessionProvider.notifier)
            .start(
              OnboardingSession(
                method: OnboardingMethod.google,
                email: outcome.email.isNotEmpty
                    ? outcome.email
                    : onboardingEmail,
                displayName: outcome.displayName,
              ),
            );
        context.push('/auth/onboarding');
      }
      // On sign-in the GoRouter redirect fires automatically.
    } catch (error) {
      if (!mounted) return;
      final message = onboardingErrorMessage(context, error);
      if (message.isNotEmpty) _showMessage(message);
    }
  }

  void _startEmailSignUp() {
    ref
        .read(onboardingSessionProvider.notifier)
        .start(const OnboardingSession(method: OnboardingMethod.emailPassword));
    context.push('/auth/onboarding');
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage(context.l10n.enterEmailFirst);
      return;
    }
    _showMessage(null);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendPasswordReset(email: email);
      if (mounted) {
        _showMessage(
          context.l10n.passwordResetSentNote,
          AuthNoticeKind.success,
        );
      }
    } catch (error) {
      if (mounted) _showMessage(onboardingErrorMessage(context, error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            // A plain scroll view, not a lazy ListView: Form.validate() has to
            // reach the password field even when the keyboard has pushed it
            // off-screen.
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.xxxl,
                AppSpacing.pagePadding,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _BrandMark(),
                  const SizedBox(height: AppSpacing.xl),
                  Semantics(
                    header: true,
                    child: Text(l10n.loginTitle, style: AppTextStyles.h1),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.loginSubtitle,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: l10n.continueWithGoogle,
                    variant: AppButtonVariant.quiet,
                    expand: true,
                    isLoading: isLoading && _googleBusy,
                    onPressed: isLoading ? null : _submitGoogle,
                  ),
                  const _OrDivider(),
                  AuthTextField(
                    controller: _emailController,
                    label: l10n.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [
                      AutofillHints.username,
                      AutofillHints.email,
                    ],
                    textDirection: TextDirection.ltr,
                    autocorrect: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (v) => validateEmailField(context, v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AuthTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    label: l10n.password,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    autocorrect: false,
                    onFieldSubmitted: (_) => isLoading ? null : _submitEmail(),
                    validator: (v) => (v == null || v.isEmpty)
                        ? l10n.loginPasswordRequired
                        : null,
                    suffixIcon: PasswordVisibilityToggle(
                      obscured: _obscurePassword,
                      onToggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      onPressed: isLoading ? null : _sendPasswordReset,
                      child: Text(l10n.forgotPassword),
                    ),
                  ),
                  if (_message != null) ...[
                    AuthNoticeBanner(message: _message!, kind: _messageKind),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  AppButton(
                    label: l10n.login,
                    onPressed: isLoading ? null : _submitEmail,
                    expand: true,
                    isLoading: isLoading && !_googleBusy,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Text(
                      l10n.dontHaveAccount,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: l10n.createAccount,
                    variant: AppButtonVariant.secondary,
                    expand: true,
                    onPressed: isLoading ? null : _startEmailSignUp,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      onPressed: () => context.go('/guest/marketplace'),
                      child: Text(
                        l10n.continueAsGuest,
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small leaf mark plus the app name. The product has no official logo yet, so
/// this is a quiet stand-in built from the theme's green rather than a hero.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.appName,
      excludeSemantics: true,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              context.l10n.appName,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.primaryGreenDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    const line = Expanded(
      flex: 2,
      child: Divider(color: AppColors.surfaceStrong, height: 1),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          line,
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                context.l10n.authOrUseEmail,
                textAlign: TextAlign.center,
                style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
              ),
            ),
          ),
          line,
        ],
      ),
    );
  }
}
