import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/features/auth/data/models/onboarding_request.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/onboarding_session.dart';
import 'package:farm2fork_mobile/features/auth/presentation/utils/onboarding_support.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_form_widgets.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/onboarding_scaffold.dart';

/// Backend businessType enum values (labels are localized).
const _businessTypes = ['individual', 'retailer', 'restaurant', 'wholesaler'];

class BuyerOnboardingScreen extends ConsumerStatefulWidget {
  const BuyerOnboardingScreen({super.key});

  @override
  ConsumerState<BuyerOnboardingScreen> createState() =>
      _BuyerOnboardingScreenState();
}

class _BuyerOnboardingScreenState extends ConsumerState<BuyerOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _cnic = TextEditingController();
  final _phone = TextEditingController();
  final _businessName = TextEditingController();
  String? _businessType;
  String? _error;

  @override
  void dispose() {
    for (final c in [_email, _password, _cnic, _phone, _businessName]) {
      c.dispose();
    }
    super.dispose();
  }

  String _businessTypeLabel(BuildContext context, String value) {
    return switch (value) {
      'retailer' => context.l10n.businessTypeRetailer,
      'restaurant' => context.l10n.businessTypeRestaurant,
      'wholesaler' => context.l10n.businessTypeWholesaler,
      _ => context.l10n.businessTypeIndividual,
    };
  }

  Future<void> _submit(OnboardingSession session) {
    return submitOnboarding(
      ref,
      context,
      _formKey,
      () => BuyerOnboardingRequest(
        credential: buildOnboardingCredential(
          session,
          email: _email.text,
          password: _password.text,
        ),
        cnic: _cnic.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        businessName: _businessName.text.trim(),
        businessType: _businessType ?? 'individual',
      ),
      (msg) => setState(() => _error = msg),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(onboardingSessionProvider);
    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/auth/login');
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final submitting = ref.watch(authControllerProvider).isLoading;

    return OnboardingScaffold(
      roleTitle: context.l10n.roleBuyer,
      session: session,
      formKey: _formKey,
      emailController: _email,
      passwordController: _password,
      cnicController: _cnic,
      phoneController: _phone,
      errorMessage: _error,
      submitting: submitting,
      onSubmit: () => _submit(session),
      roleFields: [
        AuthTextField(
          controller: _businessName,
          label: context.l10n.businessName,
          validator: (v) => validateRequiredField(context, v),
        ),
        const SizedBox(height: AppSpacing.md),
        AuthDropdown(
          label: context.l10n.businessType,
          hint: context.l10n.selectBusinessType,
          value: _businessType,
          items: [
            for (final t in _businessTypes)
              DropdownMenuItem(
                value: t,
                child: Text(_businessTypeLabel(context, t)),
              ),
          ],
          onChanged: (v) => setState(() => _businessType = v),
          validator: (v) => validateRequiredField(context, v),
        ),
      ],
    );
  }
}
