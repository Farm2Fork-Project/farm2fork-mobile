import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/onboarding_session.dart';
import 'package:farm2fork_mobile/features/auth/presentation/utils/onboarding_support.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_form_widgets.dart';

/// Holds a new email/password user until Firebase verifies their email. The
/// backend remains the only place that creates the Farm2Fork profile/session.
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _working = false;
  String? _message;

  Future<void> _resend() async {
    setState(() {
      _working = true;
      _message = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).resendEmailVerification();
      if (mounted) {
        setState(() => _message = 'A new verification email has been sent.');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _message = onboardingErrorMessage(context, error));
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _continue() async {
    final session = ref.read(onboardingSessionProvider);
    setState(() {
      _working = true;
      _message = null;
    });
    try {
      if (session?.pendingRequest case final request?) {
        await ref
            .read(authControllerProvider.notifier)
            .completeOnboarding(request);
        final state = ref.read(authControllerProvider);
        if (state.hasError) {
          final error = state.error;
          if (error is ApiException &&
              error.code == 'EMAIL_VERIFICATION_REQUIRED') {
            throw const _EmailStillUnverified();
          }
          throw error!;
        }
        ref.read(onboardingSessionProvider.notifier).clear();
      } else {
        final outcome = await ref
            .read(authControllerProvider.notifier)
            .refreshVerifiedEmailSession();
        if (outcome is FirebaseVerificationRequired) {
          throw const _EmailStillUnverified();
        }
        if (outcome is FirebaseOnboardingRequired && mounted) {
          ref
              .read(onboardingSessionProvider.notifier)
              .start(
                OnboardingSession(
                  method: OnboardingMethod.google,
                  email: outcome.email,
                  displayName: outcome.displayName,
                ),
              );
          context.go('/auth/onboarding');
        }
      }
    } on _EmailStillUnverified {
      if (mounted) {
        setState(
          () => _message =
              'Your email is not verified yet. Check your inbox, then try again.',
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _message = onboardingErrorMessage(context, error));
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(onboardingSessionProvider)?.email;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(backgroundColor: AppColors.backgroundLight),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              const Icon(
                Icons.mark_email_read_outlined,
                size: 56,
                color: AppColors.primaryGreenDark,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Verify your email', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.sm),
              Text(
                email == null || email.isEmpty
                    ? 'Open the verification link Firebase sent to your email, then return here.'
                    : 'Open the verification link Firebase sent to $email, then return here.',
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_message != null) ...[
                AuthErrorBanner(message: _message!),
                const SizedBox(height: AppSpacing.md),
              ],
              AppButton(
                label: 'I have verified my email',
                onPressed: _working ? null : _continue,
                expand: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Resend verification email',
                variant: AppButtonVariant.quiet,
                onPressed: _working ? null : _resend,
                expand: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailStillUnverified implements Exception {
  const _EmailStillUnverified();
}
