import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/section_header.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/onboarding_session.dart';
import 'package:farm2fork_mobile/features/auth/presentation/utils/onboarding_support.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_form_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  Future<void> _submitGoogle() {
    return _handleOutcome(
      () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
    );
  }

  /// A returning user signed in; a new identity is routed into onboarding.
  Future<void> _handleOutcome(
    Future<FirebaseSignInOutcome> Function() run, {
    String? onboardingEmail,
  }) async {
    setState(() => _errorMessage = null);
    try {
      final outcome = await run();
      if (!mounted) return;
      if (outcome is FirebaseOnboardingRequired) {
        ref.read(onboardingSessionProvider.notifier).start(
          OnboardingSession(
            method: OnboardingMethod.google,
            email: outcome.email.isNotEmpty ? outcome.email : onboardingEmail,
            displayName: outcome.displayName,
          ),
        );
        context.push('/auth/onboarding');
      }
      // On sign-in the GoRouter redirect fires automatically.
    } catch (error) {
      if (!mounted) return;
      final message = onboardingErrorMessage(context, error);
      if (message.isNotEmpty) setState(() => _errorMessage = message);
    }
  }

  void _startEmailSignUp() {
    ref
        .read(onboardingSessionProvider.notifier)
        .start(const OnboardingSession(method: OnboardingMethod.emailPassword));
    context.push('/auth/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                backgroundColor: AppColors.primaryGreenDark,
                borderColor: AppColors.primaryGreenDark,
                child: SectionHeader(
                  title: context.l10n.appName,
                  subtitle: context.l10n.authWelcomeSubtitle,
                  titleColor: AppColors.white,
                  subtitleColor: AppColors.primaryGreenSoft,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(context.l10n.login, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              if (_errorMessage != null) ...[
                AuthErrorBanner(message: _errorMessage!),
                const SizedBox(height: AppSpacing.md),
              ],
              AppButton(
                label: context.l10n.continueWithGoogle,
                variant: AppButtonVariant.quiet,
                expand: true,
                onPressed: isLoading ? null : _submitGoogle,
              ),
              _AuthDivider(),
              AuthTextField(
                controller: _emailController,
                label: context.l10n.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => validateRequiredField(context, v),
              ),
              const SizedBox(height: AppSpacing.md),
              AuthTextField(
                controller: _passwordController,
                label: context.l10n.password,
                obscureText: _obscurePassword,
                validator: (v) => validateRequiredField(context, v),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: context.l10n.login,
                onPressed: isLoading ? null : _submitEmail,
                expand: true,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.l10n.dontHaveAccount,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : _startEmailSignUp,
                    child: Text(
                      context.l10n.signUpWithEmail,
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              _AuthDivider(),
              AppButton(
                label: context.l10n.continueAsGuest,
                variant: AppButtonVariant.quiet,
                expand: true,
                onPressed: () => context.go('/guest/marketplace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              context.l10n.authOr,
              style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
