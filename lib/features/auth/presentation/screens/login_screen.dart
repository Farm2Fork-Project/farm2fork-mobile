import 'package:flutter/foundation.dart';
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
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorMessage = null);

    await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    final authState = ref.read(authControllerProvider);
    if (authState.hasError) {
      setState(() => _errorMessage = context.l10n.invalidCredentials);
    }
    // On success, GoRouter redirect fires automatically
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
              AuthTextField(
                controller: _emailController,
                label: context.l10n.emailOrPhone,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? context.l10n.emailOrPhone
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AuthTextField(
                controller: _passwordController,
                label: context.l10n.password,
                obscureText: _obscurePassword,
                validator: (v) =>
                    (v == null || v.isEmpty) ? context.l10n.password : null,
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {}, // stub — backend not ready
                  child: Text(
                    context.l10n.forgotPassword,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: context.l10n.login,
                onPressed: isLoading ? null : _submit,
                expand: true,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.l10n.dontHaveAccount,
                    style: AppTextStyles.small
                        .copyWith(color: AppColors.textMuted),
                  ),
                  TextButton(
                    onPressed: () => context.push('/auth/signup'),
                    child: Text(
                      context.l10n.signUp,
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
              if (kDebugMode) ...[
                const SizedBox(height: AppSpacing.lg),
                _DevHint(),
              ],
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
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'or',
              style:
                  AppTextStyles.small.copyWith(color: AppColors.textMuted),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

class _DevHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.surfaceMedium,
      borderColor: AppColors.surfaceMedium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.devTestAccounts,
            style: AppTextStyles.small
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final line in [
            'buyer@test.com / test1234',
            'farmer@test.com / test1234',
            'transporter@test.com / test1234',
          ])
            Text(
              line,
              style: AppTextStyles.small
                  .copyWith(color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}
