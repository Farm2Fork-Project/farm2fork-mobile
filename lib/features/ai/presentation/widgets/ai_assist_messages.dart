import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/features/ai/data/models/ai_models.dart';

String aiErrorMessage(BuildContext context, AiErrorKind kind) => switch (kind) {
  AiErrorKind.unavailable => context.l10n.aiUnavailable,
  AiErrorKind.tooManyRequests => context.l10n.aiTooManyRequests,
  AiErrorKind.noPriceRule => context.l10n.aiPriceNoRule,
  AiErrorKind.invalidPhoto => context.l10n.aiInvalidPhoto,
  AiErrorKind.failed => context.l10n.aiFailed,
};

enum AiNoteTone { info, warning, error }

/// Small icon + text line used for every AI caveat so they read the same.
class AiNote extends StatelessWidget {
  const AiNote({super.key, required this.text, this.tone = AiNoteTone.info});

  final String text;
  final AiNoteTone tone;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (tone) {
      AiNoteTone.info => (Icons.info_outline_rounded, AppColors.textMuted),
      AiNoteTone.warning => (Icons.warning_amber_rounded, AppColors.textDark),
      AiNoteTone.error => (Icons.error_outline_rounded, AppColors.errorRed),
    };
    final note = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.small.copyWith(color: color, height: 1.4),
          ),
        ),
      ],
    );
    if (tone != AiNoteTone.warning) return note;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.accentYellowSoft,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.accentYellow),
      ),
      child: note,
    );
  }
}
