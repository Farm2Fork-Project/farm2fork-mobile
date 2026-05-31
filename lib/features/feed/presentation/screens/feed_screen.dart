import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/widgets/feature_placeholder_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeaturePlaceholderScreen(
      title: context.l10n.feedTitle,
      description: context.l10n.feedDescription,
      icon: Icons.forum_rounded,
    );
  }
}
