import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.orders)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Center(
          child: Text(context.l10n.noDataFound, style: AppTextStyles.body),
        ),
      ),
    );
  }
}
