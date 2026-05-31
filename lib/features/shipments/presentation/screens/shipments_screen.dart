import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/widgets/feature_placeholder_screen.dart';

class ShipmentsScreen extends StatelessWidget {
  const ShipmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeaturePlaceholderScreen(
      title: context.l10n.shipmentsTitle,
      description: context.l10n.shipmentsDescription,
      icon: Icons.local_shipping_rounded,
      trustForward: true,
    );
  }
}
