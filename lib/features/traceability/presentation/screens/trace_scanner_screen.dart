import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/widgets/feature_placeholder_screen.dart';

class TraceScannerScreen extends StatelessWidget {
  const TraceScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeaturePlaceholderScreen(
      title: context.l10n.traceScannerTitle,
      description: context.l10n.traceScannerDescription,
      icon: Icons.qr_code_scanner_rounded,
      trustForward: true,
    );
  }
}
