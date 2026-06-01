import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_required_prompt.dart';

class GuestAccountScreen extends StatelessWidget {
  const GuestAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.profile, style: AppTextStyles.h3),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: AuthRequiredPrompt(
            title: context.l10n.welcomeToFarm2Fork,
            icon: Icons.person_outline_rounded,
            message: context.l10n.guestWelcomeSubtitle,
            onDismiss: () => context.go('/guest/marketplace'),
          ),
        ),
      ),
    );
  }
}
