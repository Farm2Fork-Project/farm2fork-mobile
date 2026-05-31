import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Farm2Fork/core/localization/l10n_extension.dart';
import 'package:Farm2Fork/core/localization/locale_controller.dart';
import 'package:Farm2Fork/core/theme/app_colors.dart';
import 'package:Farm2Fork/core/theme/app_sizes.dart';
import 'package:Farm2Fork/core/theme/app_typography.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(localeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profile),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.l10n.settings,
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Card(
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Text(
                        context.l10n.selectLanguage,
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      localeAsync.when(
                        data: (locale) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: locale.languageCode == 'en'
                                  ? null
                                  : () => ref
                                      .read(localeControllerProvider.notifier)
                                      .setLocale(const Locale('en')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: AppColors.white,
                                disabledBackgroundColor: AppColors.primaryGreen.withValues(alpha: 0.5),
                                disabledForegroundColor: AppColors.white,
                              ),
                              child: Text(context.l10n.english),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            ElevatedButton(
                              onPressed: locale.languageCode == 'ur'
                                  ? null
                                  : () => ref
                                      .read(localeControllerProvider.notifier)
                                      .setLocale(const Locale('ur')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: AppColors.white,
                                disabledBackgroundColor: AppColors.primaryGreen.withValues(alpha: 0.5),
                                disabledForegroundColor: AppColors.white,
                              ),
                              child: Text(context.l10n.urdu),
                            ),
                          ],
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (err, stack) => Text(context.l10n.errorOccurred),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      localeAsync.when(
                        data: (locale) => OutlinedButton(
                          onPressed: () => ref
                              .read(localeControllerProvider.notifier)
                              .toggleLocale(),
                          child: Text(context.l10n.changeLanguage),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
