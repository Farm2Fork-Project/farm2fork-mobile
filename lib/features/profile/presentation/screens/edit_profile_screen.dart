import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/pakistan_identity.dart';
import 'package:farm2fork_mobile/core/widgets/app_avatar.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_notice_banner.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import 'package:farm2fork_mobile/core/widgets/app_text_field.dart';
import 'package:farm2fork_mobile/core/widgets/section_header.dart';
import 'package:farm2fork_mobile/features/auth/presentation/utils/onboarding_support.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_form_widgets.dart';
import 'package:farm2fork_mobile/features/profile/data/models/user_profile.dart';
import 'package:farm2fork_mobile/features/profile/data/services/avatar_photo_source.dart';
import 'package:farm2fork_mobile/features/profile/presentation/providers/profile_controller.dart';
import 'package:farm2fork_mobile/features/profile/presentation/utils/profile_form_support.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);
    return profile.when(
      data: (data) => EditProfileForm(profile: data),
      loading: () => Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(title: Text(context.l10n.editProfile)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(title: Text(context.l10n.editProfile)),
        body: AppErrorState(
          message: context.l10n.profileLoadFailed,
          onRetry: () => ref.invalidate(profileControllerProvider),
        ),
      ),
    );
  }
}

/// The editable form. Only changed fields are sent; the save bar stays pinned
/// to the bottom; leaving with unsaved edits asks first.
class EditProfileForm extends ConsumerStatefulWidget {
  const EditProfileForm({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late UserProfile _baseline;
  late final Map<String, TextEditingController> _c;
  late String _businessType;
  late String _vehicleType;

  bool _saving = false;
  bool _photoBusy = false;
  String? _saveError;
  String? _photoMessage;
  AppNoticeKind _photoKind = AppNoticeKind.info;
  Set<String> _rejected = const {};

  static const _textFields = [
    'fullName',
    'phone',
    'businessName',
    'farmName',
    'cropTypes',
    'landSize',
    'vehicleNumber',
    'serviceAreas',
  ];

  @override
  void initState() {
    super.initState();
    _baseline = widget.profile;
    final v = formValuesFor(_baseline);
    final initial = {
      'fullName': v.fullName,
      'phone': v.phone,
      'businessName': v.businessName,
      'farmName': v.farmName,
      'cropTypes': v.cropTypes,
      'landSize': v.landSize,
      'vehicleNumber': v.vehicleNumber,
      'serviceAreas': v.serviceAreas,
    };
    _c = {
      for (final name in _textFields)
        name: TextEditingController(text: initial[name])
          ..addListener(_onChanged),
    };
    _businessType = v.businessType;
    _vehicleType = v.vehicleType;
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onChanged() {
    if (_rejected.isNotEmpty || _saveError != null) {
      _rejected = const {};
      _saveError = null;
    }
    setState(() {});
  }

  ProfileFormValues get _values => ProfileFormValues(
    fullName: _c['fullName']!.text,
    phone: _c['phone']!.text,
    businessName: _c['businessName']!.text,
    businessType: _businessType,
    farmName: _c['farmName']!.text,
    cropTypes: _c['cropTypes']!.text,
    landSize: _c['landSize']!.text,
    vehicleType: _vehicleType,
    vehicleNumber: _c['vehicleNumber']!.text,
    serviceAreas: _c['serviceAreas']!.text,
  );

  ProfileUpdate get _update => diffProfile(_baseline, _values);
  bool get _dirty => !_update.isEmpty;

  /// Resets the form to a freshly saved profile.
  void _rebase(UserProfile profile) {
    _baseline = profile;
    final v = formValuesFor(profile);
    void set(String name, String value) {
      final c = _c[name]!;
      if (c.text != value) c.text = value;
    }

    set('fullName', v.fullName);
    set('phone', v.phone);
    set('businessName', v.businessName);
    set('farmName', v.farmName);
    set('cropTypes', v.cropTypes);
    set('landSize', v.landSize);
    set('vehicleNumber', v.vehicleNumber);
    set('serviceAreas', v.serviceAreas);
    _businessType = v.businessType;
    _vehicleType = v.vehicleType;
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    final update = _update;
    if (update.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _saveError = null;
      _rejected = const {};
    });
    try {
      final saved = await ref
          .read(profileControllerProvider.notifier)
          .save(update);
      if (!mounted) return;
      _rebase(saved);
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.l10n.profileSaved),
            duration: AppDurations.quickConfirmation,
          ),
        );
    } catch (error) {
      if (!mounted) return;
      final rejected = error is ApiException
          ? rejectedProfileFields(error.serverMessage)
          : const <String>{};
      setState(() {
        _saving = false;
        _rejected = rejected;
        _saveError = rejected.isEmpty ? _saveMessage(error) : null;
      });
    }
  }

  String _saveMessage(Object error) {
    if (error is ApiException &&
        (error.kind == ApiErrorKind.network ||
            error.kind == ApiErrorKind.timeout)) {
      return context.l10n.authErrorNetwork;
    }
    return context.l10n.profileSaveFailed;
  }

  /// Field-level message for a value the server turned down.
  String? _serverError(String field, String label) => _rejected.contains(field)
      ? context.l10n.profileFieldRejected(label)
      : null;

  // ── photo ────────────────────────────────────────────────────────────────

  Future<void> _changePhoto() async {
    final source = await showModalBottomSheet<AvatarSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              minTileHeight: 56,
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(ctx.l10n.profilePhotoGallery),
              onTap: () => Navigator.of(ctx).pop(AvatarSource.gallery),
            ),
            ListTile(
              minTileHeight: 56,
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(ctx.l10n.profilePhotoCamera),
              onTap: () => Navigator.of(ctx).pop(AvatarSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    setState(() {
      _photoBusy = true;
      _photoMessage = null;
    });
    final l10n = context.l10n;
    try {
      final upload = await ref
          .read(avatarPhotoSourceProvider)
          .pick(source, cropTitle: l10n.profilePhotoCropTitle);
      if (upload == null) {
        if (mounted) setState(() => _photoBusy = false);
        return;
      }
      await ref.read(profileControllerProvider.notifier).uploadAvatar(upload);
      _photoResult(l10n.profilePhotoUpdated, AppNoticeKind.success);
    } on PlatformException {
      _photoResult(l10n.profilePhotoPickFailed, AppNoticeKind.error);
    } catch (_) {
      _photoResult(l10n.profilePhotoFailed, AppNoticeKind.error);
    }
  }

  Future<void> _removePhoto() async {
    final l10n = context.l10n;
    setState(() {
      _photoBusy = true;
      _photoMessage = null;
    });
    try {
      await ref.read(profileControllerProvider.notifier).removeAvatar();
      _photoResult(l10n.profilePhotoRemoved, AppNoticeKind.success);
    } catch (_) {
      _photoResult(l10n.profilePhotoFailed, AppNoticeKind.error);
    }
  }

  void _photoResult(String message, AppNoticeKind kind) {
    if (!mounted) return;
    setState(() {
      _photoBusy = false;
      _photoMessage = message;
      _photoKind = kind;
    });
  }

  // ── leaving with unsaved edits ───────────────────────────────────────────

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.discardChangesTitle, style: AppTextStyles.h3),
        content: Text(
          ctx.l10n.discardChangesMessage,
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ctx.l10n.keepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              ctx.l10n.discardChanges,
              style: const TextStyle(
                color: AppColors.errorRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (discard == true && mounted) context.pop();
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Keep the photo in step with the profile controller (upload / remove).
    final current = ref.watch(profileControllerProvider).asData?.value;
    final user = (current ?? widget.profile).user;
    final dirty = _dirty;

    return PopScope(
      canPop: !dirty || _saving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(l10n.editProfile, style: AppTextStyles.h2),
          backgroundColor: AppColors.backgroundLight,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              // Not a lazy list: Form.validate() must reach every field, and
              // off-screen fields would otherwise not exist to be checked.
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PhotoSection(
                      name: _c['fullName']!.text.trim().isNotEmpty
                          ? _c['fullName']!.text.trim()
                          : (current ?? widget.profile).displayName,
                      avatarUrl: user.avatarUrl,
                      busy: _photoBusy,
                      message: _photoMessage,
                      kind: _photoKind,
                      onChange: _photoBusy || _saving ? null : _changePhoto,
                      onRemove: _photoBusy || _saving ? null : _removePhoto,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SectionHeader(
                      title: l10n.profileSectionPersonal,
                      titleColor: AppColors.primaryGreenDark,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _c['fullName']!,
                      label: l10n.signUpName,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.name],
                      errorText: _serverError('fullName', l10n.signUpName),
                      validator: (v) => validateFullNameField(context, v),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _c['phone']!,
                      label: _baseline.user.phone?.isNotEmpty == true
                          ? l10n.signUpPhone
                          : l10n.fieldOptional(l10n.signUpPhone),
                      hintText: l10n.phoneHint,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      textDirection: TextDirection.ltr,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      errorText: _serverError('phone', l10n.signUpPhone),
                      helperText: normalizePhone(_c['phone']!.text) == null
                          ? null
                          : l10n.phoneSavedAs(
                              normalizePhone(_c['phone']!.text)!,
                            ),
                      validator: (v) {
                        final text = v?.trim() ?? '';
                        if (text.isEmpty &&
                            (_baseline.user.phone ?? '').isNotEmpty) {
                          return l10n.validationRequired;
                        }
                        return validatePhoneField(context, v);
                      },
                    ),
                    ..._roleSection(context),
                    const SizedBox(height: AppSpacing.xl),
                    SectionHeader(
                      title: l10n.profileSectionIdentity,
                      titleColor: AppColors.primaryGreenDark,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _LockedFields(
                      email: _baseline.user.email,
                      cnicMasked: _baseline.profile.maskedCnic,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: _SaveBar(
          error: _saveError,
          enabled: dirty && !_saving && !_photoBusy,
          saving: _saving,
          onSave: _save,
        ),
      ),
    );
  }

  List<Widget> _roleSection(BuildContext context) {
    final l10n = context.l10n;
    const gap = SizedBox(height: AppSpacing.md);
    switch (_baseline.profile) {
      case BuyerProfileDetails():
        final individual = _businessType == 'individual';
        return [
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: l10n.profileSectionBusiness,
            titleColor: AppColors.primaryGreenDark,
          ),
          const SizedBox(height: AppSpacing.md),
          AuthChoiceChips(
            label: l10n.businessType,
            value: _businessType,
            options: {
              'individual': l10n.businessTypeIndividual,
              'retailer': l10n.businessTypeRetailer,
              'restaurant': l10n.businessTypeRestaurant,
              'wholesaler': l10n.businessTypeWholesaler,
            },
            onChanged: (v) => setState(() => _businessType = v),
          ),
          gap,
          if (!individual)
            AppTextField(
              controller: _c['businessName']!,
              label: l10n.businessName,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              errorText: _serverError('businessName', l10n.businessName),
              validator: (v) => validateRequiredField(context, v),
            ),
        ];
      case FarmerProfileDetails(:final farmLocation):
        return [
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: l10n.profileSectionFarm,
            titleColor: AppColors.primaryGreenDark,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _c['farmName']!,
            label: l10n.farmName,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            errorText: _serverError('farmName', l10n.farmName),
            validator: (v) => validateRequiredField(context, v),
          ),
          gap,
          AppTextField(
            controller: _c['cropTypes']!,
            label: l10n.fieldOptional(l10n.cropTypes),
            hintText: l10n.cropTypesHint,
            textInputAction: TextInputAction.next,
            errorText: _serverError('cropTypes', l10n.cropTypes),
          ),
          gap,
          AppTextField(
            controller: _c['landSize']!,
            label: l10n.fieldOptional(l10n.farmSize),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            errorText: _serverError('landSizeAcres', l10n.farmSize),
            validator: (v) => validateAcresField(context, v),
          ),
          gap,
          AppCard(
            padding: EdgeInsets.zero,
            child: Material(
              type: MaterialType.transparency,
              child: ListTile(
                minTileHeight: 56,
                leading: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primaryGreenDark,
                ),
                title: Text(l10n.farmPickupLocation),
                subtitle: Text(
                  farmLocation?.complete == true
                      ? [
                          farmLocation?.city,
                          farmLocation?.province,
                        ].whereType<String>().join(', ')
                      : l10n.profileFarmLocationNotSet,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  await context.push('/settings/farm-location');
                  if (!mounted) return;
                  try {
                    await ref.read(profileControllerProvider.notifier).reload();
                  } catch (_) {
                    // The summary line just stays as it was.
                  }
                },
              ),
            ),
          ),
        ];
      case TransporterProfileDetails():
        return [
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: l10n.profileSectionVehicle,
            titleColor: AppColors.primaryGreenDark,
          ),
          const SizedBox(height: AppSpacing.md),
          AuthChoiceChips(
            label: l10n.vehicleType,
            value: _vehicleType.isEmpty ? null : _vehicleType,
            options: {
              'bike': l10n.vehicleTypeBike,
              'rickshaw': l10n.vehicleTypeRickshaw,
              'van': l10n.vehicleTypeVan,
              'truck': l10n.vehicleTypeTruck,
            },
            onChanged: (v) => setState(() => _vehicleType = v),
          ),
          gap,
          AppTextField(
            controller: _c['vehicleNumber']!,
            label: l10n.vehicleNumber,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.characters,
            textDirection: TextDirection.ltr,
            errorText: _serverError('vehicleNumber', l10n.vehicleNumber),
            validator: (v) => validateVehicleNumberField(context, v),
          ),
          gap,
          AppTextField(
            controller: _c['serviceAreas']!,
            label: l10n.fieldOptional(l10n.serviceArea),
            hintText: l10n.serviceAreasHint,
            textInputAction: TextInputAction.done,
            errorText: _serverError('serviceAreas', l10n.serviceArea),
          ),
        ];
      case OtherProfileDetails():
        return const [];
    }
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.name,
    required this.avatarUrl,
    required this.busy,
    required this.message,
    required this.kind,
    required this.onChange,
    required this.onRemove,
  });

  final String name;
  final String? avatarUrl;
  final bool busy;
  final String? message;
  final AppNoticeKind kind;
  final VoidCallback? onChange;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasPhoto = avatarUrl != null && avatarUrl!.isNotEmpty;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AppAvatar(
              name: name,
              imageUrl: avatarUrl,
              size: 96,
              semanticLabel: l10n.profilePhotoOf(name),
            ),
            if (busy)
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.black.withValues(alpha: 0.35),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppButton(
              label: hasPhoto ? l10n.profilePhotoChange : l10n.profilePhotoAdd,
              icon: Icons.photo_camera_outlined,
              variant: AppButtonVariant.secondary,
              onPressed: onChange,
            ),
            if (hasPhoto)
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  foregroundColor: AppColors.errorRed,
                ),
                onPressed: onRemove,
                child: Text(l10n.profilePhotoRemove),
              ),
          ],
        ),
        if (busy) ...[
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.profilePhotoUploading,
              style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
        if (message != null) ...[
          const SizedBox(height: AppSpacing.md),
          AppNoticeBanner(message: message!, kind: kind),
        ],
      ],
    );
  }
}

/// Email and CNIC: shown, never editable (the backend rejects both).
class _LockedFields extends StatelessWidget {
  const _LockedFields({required this.email, required this.cnicMasked});

  final String email;
  final String? cnicMasked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LockedRow(label: l10n.email, value: email),
          if (cnicMasked != null && cnicMasked!.isNotEmpty) ...[
            const Divider(
              height: AppSpacing.xl,
              color: AppColors.surfaceMedium,
            ),
            _LockedRow(label: l10n.fieldCnic, value: cnicMasked!),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.profileIdentityLocked,
            style: AppTextStyles.small.copyWith(
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedRow extends StatelessWidget {
  const _LockedRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                textDirection: TextDirection.ltr,
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const Icon(
          Icons.lock_outline_rounded,
          size: 18,
          color: AppColors.textMuted,
        ),
      ],
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.error,
    required this.enabled,
    required this.saving,
    required this.onSave,
  });

  final String? error;
  final bool enabled;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(top: BorderSide(color: AppColors.surfaceMedium)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (error != null) ...[
                AppNoticeBanner(message: error!),
                const SizedBox(height: AppSpacing.md),
              ],
              AppButton(
                label: context.l10n.saveChanges,
                expand: true,
                isLoading: saving,
                onPressed: enabled ? onSave : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
