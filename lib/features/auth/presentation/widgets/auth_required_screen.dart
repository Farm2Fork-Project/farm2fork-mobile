import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_required_prompt.dart';

/// Full-screen auth prompt shown in the Cart tab for guest users.
class AuthRequiredScreen extends StatelessWidget {
  const AuthRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.navCart, style: AppTextStyles.h3),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: AuthRequiredPrompt(
            title: context.l10n.loginRequired,
            icon: Icons.shopping_basket_outlined,
            message: context.l10n.loginToAddToCart,
            onDismiss: () => context.go('/guest/marketplace'),
          ),
        ),
      ),
    );
  }
}
