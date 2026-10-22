import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/features/ai/data/models/ai_models.dart';
import 'package:farm2fork_mobile/features/ai/data/repositories/ai_repository_provider.dart';
import 'package:farm2fork_mobile/features/ai/presentation/widgets/ai_assist_messages.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';

typedef PhotoPicker = Future<XFile?> Function(ImageSource source);

Future<XFile?> _defaultPicker(ImageSource source) => ImagePicker().pickImage(
  source: source,
  // Enough detail for grading, small enough for rural mobile data.
  maxWidth: 1600,
  imageQuality: 85,
);

String _mimeFor(String filename) {
  final name = filename.toLowerCase();
  if (name.endsWith('.png')) return 'image/png';
  if (name.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}

/// Photo quality check on the produce-details step. While the grading model
/// is untrained every result is labelled a preview; a D offers no grade.
class QualityCheckCard extends ConsumerStatefulWidget {
  const QualityCheckCard({
    super.key,
    required this.productName,
    required this.onApplyGrade,
    this.pickPhoto = _defaultPicker,
    this.onInvalidateGrade,
  });

  final String productName;
  final ValueChanged<QualityGrade> onApplyGrade;
  final PhotoPicker pickPhoto;
  final VoidCallback? onInvalidateGrade;

  @override
  ConsumerState<QualityCheckCard> createState() => _QualityCheckCardState();
}

class _QualityCheckCardState extends ConsumerState<QualityCheckCard> {
  GradableCrop? _crop;
  QualityCheck? _result;
  AiErrorKind? _error;
  bool _needCrop = false;
  bool _loading = false;

  int _requestVersion = 0;

  void _invalidate() {
    _requestVersion++;
    _result = null;
    _error = null;
    _loading = false;
    widget.onInvalidateGrade?.call();
  }

  @override
  void didUpdateWidget(covariant QualityCheckCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productName != widget.productName) {
      _invalidate();
    }
  }

  Future<void> _check(ImageSource source) async {
    final crop = _crop;
    if (crop == null) {
      setState(() => _needCrop = true);
      return;
    }
    if (!crop.supportsGrading) return;
    setState(_invalidate);
    final version = _requestVersion;
    final photo = await widget.pickPhoto(source);
    if (photo == null || !mounted || version != _requestVersion) return;
    setState(() {
      _loading = true;
      _error = null;
      _needCrop = false;
      _result = null;
    });
    try {
      final bytes = await photo.readAsBytes();
      if (!mounted || version != _requestVersion) return;
      final result = await ref
          .read(aiRepositoryProvider)
          .checkQuality(
            bytes: bytes,
            filename: photo.name,
            mimeType: _mimeFor(photo.name),
            crop: crop,
          );
      if (mounted && version == _requestVersion) {
        setState(() => _result = result);
      }
    } on AiException catch (e) {
      if (mounted && version == _requestVersion) {
        setState(() => _error = e.kind);
      }
    } catch (_) {
      if (mounted && version == _requestVersion) {
        setState(() => _error = AiErrorKind.failed);
      }
    } finally {
      if (mounted && version == _requestVersion) {
        setState(() => _loading = false);
      }
    }
  }

  String _cropLabel(BuildContext context, GradableCrop crop) => switch (crop) {
    GradableCrop.wheat => context.l10n.cropWheat,
    GradableCrop.rice => context.l10n.cropRice,
    GradableCrop.mango => context.l10n.cropMango,
    GradableCrop.maize => context.l10n.cropMaize,
    GradableCrop.other => context.l10n.cropOther,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = ref.watch(aiStatusProvider).asData?.value;
    final result = _result;

    return AppCard(
      backgroundColor: AppColors.surfaceLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.photo_camera_outlined,
                size: 18,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(l10n.aiQualityTitle, style: AppTextStyles.h3),
              ),
            ],
          ),
          if (status?.qualityModel == AiModelStatus.untrained) ...[
            const SizedBox(height: AppSpacing.sm),
            AiNote(text: l10n.aiPreviewModel, tone: AiNoteTone.warning),
          ],
          if (status != null && !status.available) ...[
            const SizedBox(height: AppSpacing.sm),
            AiNote(text: l10n.aiUnavailable, tone: AiNoteTone.error),
          ],
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<GradableCrop>(
            key: ValueKey(_crop),
            initialValue: _crop,
            decoration: InputDecoration(
              labelText: l10n.aiCropLabel,
              errorText: _needCrop ? l10n.aiNeedCrop : null,
            ),
            items: [
              for (final crop in GradableCrop.values)
                DropdownMenuItem(
                  value: crop,
                  child: Text(_cropLabel(context, crop)),
                ),
            ],
            onChanged: (crop) => setState(() {
              _crop = crop;
              _needCrop = false;
              _invalidate();
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_crop == GradableCrop.other)
            AiNote(text: l10n.aiOtherCropNoGrading),
          if (_crop != GradableCrop.other) ...[
            AppButton(
              label: l10n.aiTakePhoto,
              icon: Icons.photo_camera_rounded,
              variant: AppButtonVariant.secondary,
              expand: true,
              isLoading: _loading,
              onPressed: _loading ? null : () => _check(ImageSource.camera),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.aiChoosePhoto,
              icon: Icons.photo_library_outlined,
              variant: AppButtonVariant.quiet,
              expand: true,
              onPressed: _loading ? null : () => _check(ImageSource.gallery),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AiNote(
              text: aiErrorMessage(context, _error!),
              tone: AiNoteTone.error,
            ),
          ],
          if (result != null && result.needsReview) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.aiReviewTitle,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.primaryGreenDark,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            AiNote(
              text: switch (result.reviewReason) {
                QualityReviewReason.unfamiliarPhoto =>
                  l10n.aiReviewUnfamiliarPhoto,
                QualityReviewReason.photoCheckUnavailable =>
                  l10n.aiReviewUnavailable,
                _ => l10n.aiReviewLowConfidence,
              },
              tone: AiNoteTone.warning,
            ),
            const SizedBox(height: AppSpacing.xs),
            AiNote(text: l10n.aiReviewTips),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.aiReviewRetake,
              icon: Icons.photo_camera_rounded,
              variant: AppButtonVariant.quiet,
              onPressed: _loading ? null : () => _check(ImageSource.camera),
            ),
            AiNote(text: l10n.aiReviewManual),
          ] else if (result != null) ...[
            const SizedBox(height: AppSpacing.md),
            AiNote(text: l10n.aiGradeAdvisory),
            Text(
              l10n.aiGradeResult(
                result.modelGrade!,
                (result.confidence * 100).round(),
              ),
              style: AppTextStyles.h3.copyWith(
                color: AppColors.primaryGreenDark,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (result.modelStatus == AiModelStatus.untrained)
              AiNote(text: l10n.aiPreviewResult, tone: AiNoteTone.warning),
            if (!result.cropSupported) ...[
              const SizedBox(height: AppSpacing.xs),
              AiNote(text: l10n.aiCropNotTrained, tone: AiNoteTone.warning),
            ],
            if (result.modelStatus == AiModelStatus.trained &&
                result.lowConfidence)
              AiNote(text: l10n.aiLowConfidence),
            const SizedBox(height: AppSpacing.sm),
            if (result.suggestedListingGrade != null)
              AppButton(
                label: l10n.aiUseGrade(result.modelGrade!),
                variant: AppButtonVariant.quiet,
                onPressed: () =>
                    widget.onApplyGrade(result.suggestedListingGrade!),
              )
            else
              AiNote(text: l10n.aiGradeD, tone: AiNoteTone.warning),
          ],
        ],
      ),
    );
  }
}
