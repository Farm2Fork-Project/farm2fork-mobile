import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/pakistan_identity.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/features/auth/data/models/onboarding_request.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/onboarding_draft.dart';
import 'package:farm2fork_mobile/features/auth/presentation/utils/auth_role_l10n.dart';
import 'package:farm2fork_mobile/features/auth/presentation/utils/onboarding_support.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_form_widgets.dart';

/// Owns the text controllers and form keys for the stepped sign-up so they
/// survive moving between steps. [toDraft] snapshots them into the session.
class OnboardingFormController {
  OnboardingFormController(OnboardingDraft draft, {String? suggestedName})
    : role = draft.role {
    for (final field in OnboardingField.values) {
      _controllers[field] = TextEditingController(text: draft.value(field));
    }
    if (this[OnboardingField.fullName].text.isEmpty &&
        (suggestedName ?? '').trim().isNotEmpty) {
      this[OnboardingField.fullName].text = suggestedName!.trim();
    }
    if (this[OnboardingField.businessType].text.isEmpty) {
      this[OnboardingField.businessType].text = 'individual';
    }
  }

  OnboardingRole? role;
  final Map<OnboardingField, TextEditingController> _controllers = {};
  final Map<OnboardingStep, GlobalKey<FormState>> _keys = {};

  TextEditingController operator [](OnboardingField field) =>
      _controllers[field]!;

  GlobalKey<FormState> formKey(OnboardingStep step) =>
      _keys.putIfAbsent(step, GlobalKey<FormState>.new);

  OnboardingDraft toDraft() => OnboardingDraft(
    role: role,
    values: {
      for (final entry in _controllers.entries) entry.key: entry.value.text,
    },
  );

  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(header: true, child: Text(title, style: AppTextStyles.h2)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textMuted,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

/// Scrollable page for one step: header, then the step's fields.
class OnboardingStepPage extends StatelessWidget {
  const OnboardingStepPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.formKey,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final GlobalKey<FormState>? formKey;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepHeader(title: title, subtitle: subtitle),
        ...children,
        const SizedBox(height: AppSpacing.lg),
      ],
    );
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.lg,
        AppSpacing.pagePadding,
        AppSpacing.lg,
      ),
      child: formKey == null
          ? body
          : AutofillGroup(
              child: Form(key: formKey, child: body),
            ),
    );
  }
}

// ── Step 1: role ────────────────────────────────────────────────────────────

class OnboardingRoleStep extends StatelessWidget {
  const OnboardingRoleStep({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final OnboardingRole? selected;
  final ValueChanged<OnboardingRole> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget card(OnboardingRole role, AppUserRole appRole) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: _RoleCard(
        icon: appRole.icon,
        label: appRole.localizedLabel(context),
        description: appRole.localizedDescription(context),
        selected: selected == role,
        onTap: () => onSelected(role),
      ),
    );
    return OnboardingStepPage(
      title: l10n.onboardingRoleTitle,
      subtitle: l10n.onboardingRoleSubtitle,
      children: [
        card(OnboardingRole.farmer, AppUserRole.farmer),
        card(OnboardingRole.buyer, AppUserRole.buyer),
        card(OnboardingRole.transporter, AppUserRole.transporter),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: AppCard(
        onTap: onTap,
        backgroundColor: selected
            ? AppColors.primaryGreenSoft
            : AppColors.white,
        borderColor: selected
            ? AppColors.primaryGreen
            : AppColors.surfaceMedium,
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: selected
                  ? AppColors.white
                  : AppColors.primaryGreenSoft,
              child: Icon(icon, color: AppColors.primaryGreenDark),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textMuted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: selected ? 22 : 14,
              color: selected ? AppColors.primaryGreen : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 2: account (new email accounts) ────────────────────────────────────

class OnboardingAccountStep extends StatefulWidget {
  const OnboardingAccountStep({
    super.key,
    required this.form,
    required this.formKey,
    required this.emailError,
    required this.onEmailChanged,
    required this.onSubmit,
  });

  final OnboardingFormController form;
  final GlobalKey<FormState> formKey;
  final String? emailError;
  final VoidCallback onEmailChanged;
  final VoidCallback onSubmit;

  @override
  State<OnboardingAccountStep> createState() => _OnboardingAccountStepState();
}

class _OnboardingAccountStepState extends State<OnboardingAccountStep> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final form = widget.form;
    final password = form[OnboardingField.password];
    return OnboardingStepPage(
      title: l10n.onboardingAccountTitle,
      subtitle: l10n.onboardingAccountSubtitle,
      formKey: widget.formKey,
      children: [
        AuthTextField(
          controller: form[OnboardingField.email],
          label: l10n.email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          textDirection: TextDirection.ltr,
          autocorrect: false,
          errorText: widget.emailError,
          onChanged: (_) => widget.onEmailChanged(),
          validator: (v) => validateEmailField(context, v),
        ),
        const SizedBox(height: AppSpacing.md),
        AuthTextField(
          controller: password,
          label: l10n.password,
          obscureText: _obscure,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          autocorrect: false,
          helperText: l10n.passwordRuleHint,
          onChanged: (_) => setState(() {}),
          onFieldSubmitted: (_) => widget.onSubmit(),
          validator: (v) => validatePasswordField(context, v),
          suffixIcon: PasswordVisibilityToggle(
            obscured: _obscure,
            onToggle: () => setState(() => _obscure = !_obscure),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: password,
          builder: (_, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : PasswordStrengthMeter(password: value.text),
        ),
      ],
    );
  }
}

// ── Step 3: about you / farm / vehicle ──────────────────────────────────────

class OnboardingDetailsStep extends StatefulWidget {
  const OnboardingDetailsStep({
    super.key,
    required this.form,
    required this.formKey,
    required this.role,
    required this.googleEmail,
    required this.onSubmit,
  });

  final OnboardingFormController form;
  final GlobalKey<FormState> formKey;
  final OnboardingRole role;

  /// Set on the Google path: shown as the identity chip.
  final String? googleEmail;
  final VoidCallback onSubmit;

  @override
  State<OnboardingDetailsStep> createState() => _OnboardingDetailsStepState();
}

class _OnboardingDetailsStepState extends State<OnboardingDetailsStep> {
  OnboardingFormController get form => widget.form;

  Widget _gap() => const SizedBox(height: AppSpacing.md);

  Widget _nameField({required TextInputAction action}) => AuthTextField(
    controller: form[OnboardingField.fullName],
    label: context.l10n.signUpName,
    hintText: context.l10n.fullNameHint,
    textInputAction: action,
    textCapitalization: TextCapitalization.words,
    autofillHints: const [AutofillHints.name],
    validator: (v) => validateFullNameField(context, v),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (title, subtitle) = switch (widget.role) {
      OnboardingRole.farmer => (
        l10n.onboardingFarmTitle,
        l10n.onboardingFarmSubtitle,
      ),
      OnboardingRole.transporter => (
        l10n.onboardingVehicleTitle,
        l10n.onboardingVehicleSubtitle,
      ),
      OnboardingRole.buyer => (
        l10n.onboardingBuyerTitle,
        l10n.onboardingBuyerSubtitle,
      ),
    };
    return OnboardingStepPage(
      title: title,
      subtitle: subtitle,
      formKey: widget.formKey,
      children: [
        if ((widget.googleEmail ?? '').isNotEmpty) ...[
          GoogleIdentityChip(email: widget.googleEmail!),
          _gap(),
        ],
        ...switch (widget.role) {
          OnboardingRole.buyer => _buyer(context),
          OnboardingRole.farmer => _farmer(context),
          OnboardingRole.transporter => _transporter(context),
        },
      ],
    );
  }

  List<Widget> _buyer(BuildContext context) {
    final l10n = context.l10n;
    final type = form[OnboardingField.businessType].text;
    final isIndividual = type == 'individual';
    return [
      _nameField(action: TextInputAction.done),
      _gap(),
      AuthChoiceChips(
        label: l10n.businessType,
        value: type,
        options: {
          'individual': l10n.businessTypeIndividual,
          'retailer': l10n.businessTypeRetailer,
          'restaurant': l10n.businessTypeRestaurant,
          'wholesaler': l10n.businessTypeWholesaler,
        },
        onChanged: (v) => setState(() {
          form[OnboardingField.businessType].text = v;
        }),
      ),
      _gap(),
      if (isIndividual)
        Text(
          l10n.businessIndividualNote,
          style: AppTextStyles.small.copyWith(
            color: AppColors.textMuted,
            height: 1.4,
          ),
        )
      else
        AuthTextField(
          controller: form[OnboardingField.businessName],
          label: l10n.businessName,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          onFieldSubmitted: (_) => widget.onSubmit(),
          validator: (v) => validateRequiredField(context, v),
        ),
    ];
  }

  List<Widget> _farmer(BuildContext context) {
    final l10n = context.l10n;
    return [
      _nameField(action: TextInputAction.next),
      _gap(),
      AuthTextField(
        controller: form[OnboardingField.farmName],
        label: l10n.farmName,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        validator: (v) => validateRequiredField(context, v),
      ),
      _gap(),
      AuthTextField(
        controller: form[OnboardingField.cropTypes],
        label: l10n.fieldOptional(l10n.cropTypes),
        hintText: l10n.cropTypesHint,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.sentences,
      ),
      _gap(),
      AuthTextField(
        controller: form[OnboardingField.landSize],
        label: l10n.fieldOptional(l10n.farmSize),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => widget.onSubmit(),
        validator: (v) => validateAcresField(context, v),
      ),
    ];
  }

  List<Widget> _transporter(BuildContext context) {
    final l10n = context.l10n;
    final vehicle = form[OnboardingField.vehicleType].text;
    return [
      _nameField(action: TextInputAction.next),
      _gap(),
      FormField<String>(
        initialValue: vehicle,
        validator: (_) => form[OnboardingField.vehicleType].text.isEmpty
            ? l10n.validationRequired
            : null,
        builder: (state) => AuthChoiceChips(
          label: l10n.vehicleType,
          value: vehicle.isEmpty ? null : vehicle,
          errorText: state.errorText,
          options: {
            'bike': l10n.vehicleTypeBike,
            'rickshaw': l10n.vehicleTypeRickshaw,
            'van': l10n.vehicleTypeVan,
            'truck': l10n.vehicleTypeTruck,
          },
          onChanged: (v) => setState(() {
            form[OnboardingField.vehicleType].text = v;
            state.didChange(v);
          }),
        ),
      ),
      _gap(),
      AuthTextField(
        controller: form[OnboardingField.vehicleNumber],
        label: l10n.vehicleNumber,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.characters,
        textDirection: TextDirection.ltr,
        validator: (v) => validateVehicleNumberField(context, v),
      ),
      _gap(),
      AuthTextField(
        controller: form[OnboardingField.licenseNumber],
        label: l10n.vehicleLicense,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.characters,
        textDirection: TextDirection.ltr,
        validator: (v) => validateRequiredField(context, v),
      ),
      _gap(),
      AuthTextField(
        controller: form[OnboardingField.serviceAreas],
        label: l10n.fieldOptional(l10n.serviceArea),
        hintText: l10n.serviceAreasHint,
        textInputAction: TextInputAction.done,
        textCapitalization: TextCapitalization.words,
        onFieldSubmitted: (_) => widget.onSubmit(),
      ),
    ];
  }
}

/// "Signed in with Google" confirmation, keeping the address LTR.
class GoogleIdentityChip extends StatelessWidget {
  const GoogleIdentityChip({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '${context.l10n.onboardingSignedInWithGoogle}: $email',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryGreenSoft,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.verified_user_rounded,
              size: 20,
              color: AppColors.primaryGreenDark,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.onboardingSignedInWithGoogle,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryGreenDark,
                    ),
                  ),
                  Text(
                    email,
                    textDirection: TextDirection.ltr,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.primaryGreenDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 4 (farmers): pickup location ───────────────────────────────────────

class OnboardingPickupStep extends StatefulWidget {
  const OnboardingPickupStep({
    super.key,
    required this.form,
    required this.formKey,
    required this.onSubmit,
  });

  final OnboardingFormController form;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;

  @override
  State<OnboardingPickupStep> createState() => _OnboardingPickupStepState();
}

class _OnboardingPickupStepState extends State<OnboardingPickupStep> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final form = widget.form;
    final province = form[OnboardingField.province].text;
    const gap = SizedBox(height: AppSpacing.md);
    return OnboardingStepPage(
      title: l10n.onboardingPickupTitle,
      subtitle: l10n.onboardingPickupSubtitle,
      formKey: widget.formKey,
      children: [
        AuthTextField(
          controller: form[OnboardingField.address],
          label: l10n.streetAddress,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.streetAddressLine1],
          validator: (v) => validateRequiredField(context, v),
        ),
        gap,
        AuthTextField(
          controller: form[OnboardingField.city],
          label: l10n.city,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.addressCity],
          validator: (v) => validateRequiredField(context, v),
        ),
        gap,
        AuthDropdown(
          label: l10n.province,
          hint: l10n.province,
          value: province.isEmpty ? null : province,
          items: [
            for (final p in pakistanProvinces)
              DropdownMenuItem(
                value: p,
                child: Text(
                  provinceLabel(context, p),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (v) => setState(() {
            form[OnboardingField.province].text = v ?? '';
          }),
          validator: (v) => validateRequiredField(context, v),
        ),
        gap,
        AuthTextField(
          controller: form[OnboardingField.lat],
          label: l10n.locationLatitude,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          textInputAction: TextInputAction.next,
          textDirection: TextDirection.ltr,
          validator: (v) => validateCoordinateField(
            context,
            v,
            pakistanLatRange.$1,
            pakistanLatRange.$2,
          ),
        ),
        gap,
        AuthTextField(
          controller: form[OnboardingField.lng],
          label: l10n.locationLongitude,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          textInputAction: TextInputAction.done,
          textDirection: TextDirection.ltr,
          helperText: l10n.locationCoordinatesHelp,
          onFieldSubmitted: (_) => widget.onSubmit(),
          validator: (v) => validateCoordinateField(
            context,
            v,
            pakistanLngRange.$1,
            pakistanLngRange.$2,
          ),
        ),
      ],
    );
  }
}

// ── Last step: identity ─────────────────────────────────────────────────────

class OnboardingIdentityStep extends StatefulWidget {
  const OnboardingIdentityStep({
    super.key,
    required this.form,
    required this.formKey,
    required this.errorMessage,
    required this.onSubmit,
  });

  final OnboardingFormController form;
  final GlobalKey<FormState> formKey;
  final String? errorMessage;
  final VoidCallback onSubmit;

  @override
  State<OnboardingIdentityStep> createState() => _OnboardingIdentityStepState();
}

class _OnboardingIdentityStepState extends State<OnboardingIdentityStep> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cnic = widget.form[OnboardingField.cnic];
    final phone = widget.form[OnboardingField.phone];
    final digits = cnicDigits(cnic.text).length;
    final complete = digits == 13;
    final normalizedPhone = normalizePhone(phone.text);

    return OnboardingStepPage(
      title: l10n.onboardingIdentityTitle,
      subtitle: l10n.onboardingIdentitySubtitle,
      formKey: widget.formKey,
      children: [
        AuthTextField(
          controller: cnic,
          label: l10n.fieldCnic,
          hintText: l10n.cnicHint,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          textDirection: TextDirection.ltr,
          autocorrect: false,
          inputFormatters: const [CnicInputFormatter()],
          helperText: complete
              ? l10n.cnicComplete
              : l10n.cnicDigitsProgress(digits),
          onChanged: (_) => setState(() {}),
          validator: (v) => validateCnicField(context, v),
          suffixIcon: complete
              ? const Icon(Icons.check_circle_rounded, color: AppColors.success)
              : null,
        ),
        const SizedBox(height: AppSpacing.md),
        AuthTextField(
          controller: phone,
          label: l10n.fieldOptional(l10n.signUpPhone),
          hintText: l10n.phoneHint,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          textDirection: TextDirection.ltr,
          autofillHints: const [AutofillHints.telephoneNumber],
          helperText: normalizedPhone == null
              ? null
              : l10n.phoneSavedAs(normalizedPhone),
          onChanged: (_) => setState(() {}),
          onFieldSubmitted: (_) => widget.onSubmit(),
          validator: (v) => validatePhoneField(context, v),
        ),
        if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          AuthErrorBanner(message: widget.errorMessage!),
        ],
      ],
    );
  }
}

/// Dropdown styled to match [AuthTextField] (province picker).
class AuthDropdown extends StatelessWidget {
  const AuthDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final String hint;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.small.copyWith(color: AppColors.textMuted),
        errorMaxLines: 3,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}
