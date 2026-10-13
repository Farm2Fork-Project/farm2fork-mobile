import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/features/auth/data/models/onboarding_request.dart';
import 'package:farm2fork_mobile/features/auth/data/services/firebase_auth_gateway.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/onboarding_draft.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/onboarding_session.dart';
import 'package:farm2fork_mobile/features/auth/presentation/utils/onboarding_support.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_form_widgets.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/onboarding_form.dart';

/// Stepped sign-up: Role -> Account (new email accounts) -> About you / farm /
/// vehicle -> Pickup (farmers) -> Identity. What the user typed lives in
/// [OnboardingSession.draft], so going back (or leaving and returning) keeps it.
class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  OnboardingFormController? _form;
  OnboardingStep _step = OnboardingStep.role;
  String? _error;
  String? _emailError;

  @override
  void dispose() {
    _form?.dispose();
    super.dispose();
  }

  List<OnboardingStep> _stepsFor(OnboardingSession session) =>
      onboardingStepsFor(_form?.role, needsAccount: session.isEmailPassword);

  void _persist() {
    final form = _form;
    if (form == null) return;
    ref.read(onboardingSessionProvider.notifier).updateDraft(form.toDraft());
  }

  void _goTo(OnboardingStep step) {
    _persist();
    setState(() {
      _step = step;
      _error = null;
    });
  }

  void _selectRole(OnboardingSession session, OnboardingRole role) {
    final form = _form!;
    form.role = role;
    final steps = _stepsFor(session);
    _goTo(steps[steps.indexOf(OnboardingStep.role) + 1]);
  }

  void _back(OnboardingSession session) {
    final steps = _stepsFor(session);
    final index = steps.indexOf(_step);
    if (index > 0) {
      _goTo(steps[index - 1]);
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/auth/login');
    }
  }

  void _next(OnboardingSession session) {
    final form = _form!;
    final state = form.formKey(_step).currentState;
    if (state != null && !state.validate()) return;
    final steps = _stepsFor(session);
    final index = steps.indexOf(_step);
    if (_step == OnboardingStep.identity) {
      _submit(session);
    } else {
      _goTo(steps[index + 1]);
    }
  }

  Future<void> _submit(OnboardingSession session) {
    final form = _form!;
    _persist();
    return submitOnboarding(
      ref,
      context,
      form.formKey(OnboardingStep.identity),
      () => buildOnboardingRequest(session, form.toDraft()),
      (msg) => setState(() => _error = msg),
      onFailure: (error) {
        // The address was typed several steps ago: take the user back to it.
        if (error is AuthGatewayException &&
            error.error == AuthGatewayError.emailAlreadyInUse &&
            session.isEmailPassword) {
          setState(() {
            _step = OnboardingStep.account;
            _emailError = context.l10n.authErrorEmailInUse;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(onboardingSessionProvider);

    // Reached without an active onboarding (e.g. deep link): back to login.
    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/auth/login');
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final form = _form ??= OnboardingFormController(
      session.draft,
      suggestedName: session.displayName,
    );

    final steps = _stepsFor(session);
    final index = steps.indexOf(_step).clamp(0, steps.length - 1);
    final submitting = ref.watch(authControllerProvider).isLoading;
    final l10n = context.l10n;
    final isLast = _step == OnboardingStep.identity;

    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back(session);
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          leading: BackButton(onPressed: () => _back(session)),
          title: Text(l10n.createAccount, style: AppTextStyles.h3),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                ),
                child: AuthStepIndicator(
                  current: index + 1,
                  total: steps.length,
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  // The default layout centres the step; steps are top-anchored
                  // pages that should fill the space under the progress bar.
                  layoutBuilder: (current, previous) => Stack(
                    fit: StackFit.expand,
                    children: [...previous, ?current],
                  ),
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 180),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _stepBody(session, form),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _step == OnboardingStep.role
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.sm,
                    AppSpacing.pagePadding,
                    AppSpacing.md,
                  ),
                  child: AppButton(
                    label: isLast ? l10n.createAccount : l10n.next,
                    expand: true,
                    isLoading: isLast && submitting,
                    onPressed: submitting ? null : () => _next(session),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _stepBody(OnboardingSession session, OnboardingFormController form) {
    void submit() => _next(session);
    return switch (_step) {
      OnboardingStep.role => OnboardingRoleStep(
        selected: form.role,
        onSelected: (role) => _selectRole(session, role),
      ),
      OnboardingStep.account => OnboardingAccountStep(
        form: form,
        formKey: form.formKey(OnboardingStep.account),
        emailError: _emailError,
        onEmailChanged: () {
          if (_emailError != null) setState(() => _emailError = null);
        },
        onSubmit: submit,
      ),
      OnboardingStep.details => OnboardingDetailsStep(
        form: form,
        formKey: form.formKey(OnboardingStep.details),
        role: form.role ?? OnboardingRole.buyer,
        googleEmail: session.isEmailPassword ? null : session.email,
        onSubmit: submit,
      ),
      OnboardingStep.pickup => OnboardingPickupStep(
        form: form,
        formKey: form.formKey(OnboardingStep.pickup),
        onSubmit: submit,
      ),
      OnboardingStep.identity => OnboardingIdentityStep(
        form: form,
        formKey: form.formKey(OnboardingStep.identity),
        errorMessage: _error,
        onSubmit: submit,
      ),
    };
  }
}
