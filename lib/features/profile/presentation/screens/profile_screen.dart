import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/localization/locale_controller.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/section_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(localeControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.profile, style: AppTextStyles.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          AppCard(
            backgroundColor: AppColors.primaryGreenDark,
            borderColor: AppColors.primaryGreenDark,
            child: SectionHeader(
              title: context.l10n.settings,
              subtitle: context.l10n.selectLanguage,
              titleColor: AppColors.white,
              subtitleColor: AppColors.primaryGreenSoft,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: context.l10n.selectLanguage),
                const SizedBox(height: AppSpacing.lg),
                localeAsync.when(
                  data: (locale) => Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppButton(
                        label: context.l10n.english,
                        variant: locale.languageCode == 'en'
                            ? AppButtonVariant.primary
                            : AppButtonVariant.quiet,
                        onPressed: locale.languageCode == 'en'
                            ? null
                            : () => ref
                                  .read(localeControllerProvider.notifier)
                                  .setLocale(const Locale('en')),
                      ),
                      AppButton(
                        label: context.l10n.urdu,
                        variant: locale.languageCode == 'ur'
                            ? AppButtonVariant.primary
                            : AppButtonVariant.quiet,
                        onPressed: locale.languageCode == 'ur'
                            ? null
                            : () => ref
                                  .read(localeControllerProvider.notifier)
                                  .setLocale(const Locale('ur')),
                      ),
                    ],
                  ),
                  loading: () => const CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                  error: (err, stack) => Text(context.l10n.errorOccurred),
                ),
                const SizedBox(height: AppSpacing.lg),
                localeAsync.when(
                  data: (locale) => AppButton(
                    label: context.l10n.changeLanguage,
                    icon: Icons.translate_rounded,
                    variant: AppButtonVariant.secondary,
                    expand: true,
                    onPressed: () => ref
                        .read(localeControllerProvider.notifier)
                        .toggleLocale(),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
