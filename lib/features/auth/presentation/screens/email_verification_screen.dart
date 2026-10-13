import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
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
  /// How long to wait before the verification email can be sent again.
  static const _resendCooldown = 45;

  bool _working = false;
  bool _resending = false;
  String? _message;
  AuthNoticeKind _messageKind = AuthNoticeKind.info;
  int _secondsLeft = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendCooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(
        () => _secondsLeft = (_secondsLeft - 1).clamp(0, _resendCooldown),
      );
      if (_secondsLeft == 0) timer.cancel();
    });
  }

  void _show(String? message, AuthNoticeKind kind) => setState(() {
    _message = message;
    _messageKind = kind;
  });

  Future<void> _resend() async {
    setState(() => _resending = true);
    _show(null, AuthNoticeKind.info);
    try {
      await ref.read(authControllerProvider.notifier).resendEmailVerification();
      if (mounted) {
        _show(context.l10n.verificationResentNote, AuthNoticeKind.success);
        _startCooldown();
      }
    } catch (error) {
      if (mounted) {
        _show(onboardingErrorMessage(context, error), AuthNoticeKind.error);
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  /// Wrong address? Drop the half-finished sign-up and start again.
  Future<void> _useDifferentEmail() async {
    setState(() => _working = true);
    try {
      await ref.read(authControllerProvider.notifier).signOut();
      ref.read(onboardingSessionProvider.notifier).clear();
      if (mounted) context.go('/auth/login');
    } catch (error) {
      if (mounted) {
        _show(onboardingErrorMessage(context, error), AuthNoticeKind.error);
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _continue() async {
    final session = ref.read(onboardingSessionProvider);
    setState(() => _working = true);
    _show(null, AuthNoticeKind.info);
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
        _show(context.l10n.verificationStillPendingNote, AuthNoticeKind.info);
      }
    } catch (error) {
      if (mounted) {
        _show(onboardingErrorMessage(context, error), AuthNoticeKind.error);
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final email = ref.watch(onboardingSessionProvider)?.email;
    final hasEmail = email != null && email.isNotEmpty;
    final busy = _working || _resending;
    final cooling = _secondsLeft > 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(backgroundColor: AppColors.backgroundLight),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreenSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_unread_outlined,
                size: 36,
                color: AppColors.primaryGreenDark,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Semantics(
              header: true,
              child: Text(l10n.verifyYourEmailTitle, style: AppTextStyles.h2),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasEmail
                  ? l10n.verifyYourEmailBody(email)
                  : l10n.verifyYourEmailBodyGeneric,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.verifyCheckSpam,
              style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_message != null) ...[
              AuthNoticeBanner(message: _message!, kind: _messageKind),
              const SizedBox(height: AppSpacing.lg),
            ],
            AppButton(
              label: l10n.iHaveVerifiedMyEmail,
              onPressed: busy ? null : _continue,
              isLoading: _working,
              expand: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: cooling
                  ? l10n.verifyResendIn(_secondsLeft)
                  : l10n.resendVerificationEmail,
              variant: AppButtonVariant.quiet,
              onPressed: busy || cooling ? null : _resend,
              isLoading: _resending,
              expand: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: busy ? null : _useDifferentEmail,
                child: Text(l10n.verifyUseDifferentEmail),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailStillUnverified implements Exception {
  const _EmailStillUnverified();
}
