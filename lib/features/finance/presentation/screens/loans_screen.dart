import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/widgets/feature_placeholder_screen.dart';

class LoansScreen extends StatelessWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeaturePlaceholderScreen(
      title: context.l10n.loansTitle,
      description: context.l10n.loansDescription,
      icon: Icons.account_balance_rounded,
      trustForward: true,
    );
  }
}
