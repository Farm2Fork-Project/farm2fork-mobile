import 'package:flutter/material.dart';
import 'package:Farm2Fork/core/theme/app_colors.dart';
import 'package:Farm2Fork/core/theme/app_sizes.dart';
import 'package:Farm2Fork/core/theme/app_typography.dart';
import 'package:Farm2Fork/core/localization/l10n_extension.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.marketplace),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Center(
          child: Card(
            color: AppColors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.welcome,
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    context.l10n.appName,
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.noDataFound,
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
