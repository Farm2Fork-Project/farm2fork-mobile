import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_form_widgets.dart';

class BuyerSignupScreen extends ConsumerStatefulWidget {
  const BuyerSignupScreen({super.key});

  @override
  ConsumerState<BuyerSignupScreen> createState() => _BuyerSignupScreenState();
}

class _BuyerSignupScreenState extends ConsumerState<BuyerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorMessage = null);

    await ref
        .read(authControllerProvider.notifier)
        .signUp(
          request: BuyerSignUpRequest(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
          ),
        );

    if (!mounted) return;
    if (ref.read(authControllerProvider).hasError) {
      setState(() => _errorMessage = context.l10n.invalidCredentials);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.signUpSuccess)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.roleBuyer, style: AppTextStyles.h3),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            if (_errorMessage != null) ...[
              AuthErrorBanner(message: _errorMessage!),
              const SizedBox(height: AppSpacing.md),
            ],
            AuthTextField(
              controller: _nameController,
              label: context.l10n.signUpName,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? context.l10n.signUpName
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
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
              controller: _phoneController,
              label: context.l10n.signUpPhone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.md),
            AuthTextField(
              controller: _passwordController,
              label: context.l10n.password,
              obscureText: _obscurePassword,
              validator: (v) =>
                  (v == null || v.length < 6) ? context.l10n.password : null,
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
            AuthTextField(
              controller: _confirmController,
              label: context.l10n.confirmPassword,
              obscureText: true,
              validator: (v) => v != _passwordController.text
                  ? context.l10n.confirmPassword
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: context.l10n.createAccount,
              onPressed: isLoading ? null : _submit,
              expand: true,
            ),
          ],
        ),
      ),
    );
  }
}
