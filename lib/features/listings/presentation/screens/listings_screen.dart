import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/widgets/feature_placeholder_screen.dart';

class ListingsScreen extends StatelessWidget {
  const ListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeaturePlaceholderScreen(
      title: context.l10n.listingsTitle,
      description: context.l10n.listingsDescription,
      icon: Icons.inventory_2_rounded,
    );
  }
}
