import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import '../providers/listings_controller.dart';
import 'create_listing_screen.dart';

class EditListingScreen extends ConsumerWidget {
  const EditListingScreen({super.key, required this.productId});
  final String productId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(listingsControllerProvider);
    return listings.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        body: AppErrorState(
          message: context.l10n.listingActionFailed,
          onRetry: () => ref.invalidate(listingsControllerProvider),
        ),
      ),
      data: (products) {
        final product = products
            .where((item) => item.id == productId)
            .firstOrNull;
        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: AppEmptyState(message: context.l10n.noDataFound),
          );
        }
        return CreateListingScreen(
          key: ValueKey(productId),
          initialProduct: product,
        );
      },
    );
  }
}
