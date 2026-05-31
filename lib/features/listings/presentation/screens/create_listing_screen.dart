import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/widgets/feature_placeholder_screen.dart';

class CreateListingScreen extends StatelessWidget {
  const CreateListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeaturePlaceholderScreen(
      title: context.l10n.createListingTitle,
      description: context.l10n.createListingDescription,
      icon: Icons.add_business_rounded,
    );
  }
}
