import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/features/orders/data/models/order_quote.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/number_formatters.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_text_field.dart';
import 'package:farm2fork_mobile/core/widgets/section_header.dart';
import 'package:farm2fork_mobile/features/cart/data/models/cart_item.dart';
import 'package:farm2fork_mobile/features/cart/data/models/farmer_cart_group.dart';
import 'package:farm2fork_mobile/features/cart/presentation/providers/cart_controller.dart';
import 'package:farm2fork_mobile/features/cart/presentation/providers/checkout_controller.dart';
import 'package:farm2fork_mobile/features/orders/data/models/order.dart';

/// Buyer checkout: enter a shipping address, review the per-farmer summary, and
/// place one order per farmer group (One-Order-One-Farmer §6.1).
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, this.farmerId});

  /// When set, only this farmer's group is checked out (per-group checkout from
  /// the cart). When null, every farmer group is placed as a separate order.
  final String? farmerId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _province = TextEditingController();
  final _zip = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  bool _quoting = false;
  String? _quoteKey;
  Map<String, OrderQuote> _quotes = {};
  String? _quoteError;
  String _key(List<FarmerCartGroup> groups) => jsonEncode([
    _street.text,
    _city.text,
    _province.text,
    _zip.text,
    _lat.text,
    _lng.text,
    groups
        .map(
          (g) => [
            g.farmerId,
            g.items.map((i) => [i.product.id, i.quantity]).toList(),
          ],
        )
        .toList(),
  ]);

  @override
  void dispose() {
    _street.dispose();
    _city.dispose();
    _province.dispose();
    _zip.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final address = OrderAddress(
      street: _street.text.trim(),
      city: _city.text.trim(),
      province: _province.text.trim(),
      zip: _zip.text.trim().isEmpty ? null : _zip.text.trim(),
      lat: double.parse(_lat.text),
      lng: double.parse(_lng.text),
    );

    final groups = ref
        .read(farmerCartGroupsProvider)
        .where((g) => widget.farmerId == null || g.farmerId == widget.farmerId)
        .toList();
    final key = _key(groups);
    if (_quoteKey != key) {
      setState(() {
        _quoting = true;
        _quoteError = null;
      });
      try {
        final quotes = await ref
            .read(checkoutControllerProvider.notifier)
            .quote(address, farmerId: widget.farmerId);
        if (mounted) {
          setState(() {
            _quotes = quotes;
            _quoteKey = key;
          });
        }
      } on Object {
        if (mounted) {
          setState(() => _quoteError = context.l10n.deliveryQuoteFailed);
        }
      } finally {
        if (mounted) setState(() => _quoting = false);
      }
      return;
    }
    final result = await ref
        .read(checkoutControllerProvider.notifier)
        .submit(address, farmerId: widget.farmerId);

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    if (result.placed.isNotEmpty) {
      messenger.showSnackBar(
        _snack(
          result.isFullSuccess
              ? context.l10n.ordersPlacedCount(result.placedCount)
              : context.l10n.orderPlacementFailed,
          result.isFullSuccess ? AppColors.success : AppColors.errorRed,
        ),
      );
      final location = Uri(
        path: '/payments',
        queryParameters: {
          'orderId': result.placed.map((order) => order.id).toList(),
        },
      ).toString();
      context.go(location);
    } else {
      messenger.showSnackBar(
        _snack(context.l10n.orderPlacementFailed, AppColors.errorRed),
      );
    }
  }

  SnackBar _snack(String message, Color color) => SnackBar(
    content: Text(
      message,
      style: AppTextStyles.small.copyWith(color: AppColors.white),
    ),
    backgroundColor: color,
    duration: AppDurations.standardMessage,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final allGroups = ref.watch(farmerCartGroupsProvider);
    final groups = widget.farmerId == null
        ? allGroups
        : allGroups.where((g) => g.farmerId == widget.farmerId).toList();
    final isSubmitting =
        ref.watch(checkoutControllerProvider).isLoading || _quoting;
    final quoted = _quoteKey == _key(groups);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.checkoutTitle, style: AppTextStyles.h3),
      ),
      body: groups.isEmpty
          ? Center(
              child: Text(
                context.l10n.cartEmpty,
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.pagePadding),
                      child: Form(
                        key: _formKey,
                        onChanged: () => setState(() {}),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(title: context.l10n.shippingAddress),
                            const SizedBox(height: AppSpacing.sm),
                            _AddressForm(
                              street: _street,
                              city: _city,
                              province: _province,
                              zip: _zip,
                              lat: _lat,
                              lng: _lng,
                              enabled: !isSubmitting,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            SectionHeader(title: context.l10n.orderSummary),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              context.l10n.separateOrdersNote,
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            for (final group in groups) ...[
                              _OrderGroupCard(
                                group: group,
                                locale: locale,
                                quote: quoted ? _quotes[group.farmerId] : null,
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_quoteError != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _quoteError!,
                        style: const TextStyle(color: AppColors.errorRed),
                      ),
                    ),
                  _SubmitBar(
                    groupCount: groups.length,
                    isSubmitting: isSubmitting,
                    onSubmit: _submit,
                    quoted: quoted,
                  ),
                ],
              ),
            ),
    );
  }
}

class _AddressForm extends StatelessWidget {
  const _AddressForm({
    required this.street,
    required this.city,
    required this.province,
    required this.zip,
    required this.lat,
    required this.lng,
    required this.enabled,
  });

  final TextEditingController street;
  final TextEditingController city;
  final TextEditingController province;
  final TextEditingController zip;
  final TextEditingController lat, lng;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? context.l10n.fieldRequired : null;

    String? coordinate(String? value, double min, double max) {
      final n = double.tryParse(value ?? '');
      return n == null || !n.isFinite || n < min || n > max
          ? context.l10n.locationInvalid
          : null;
    }

    return Column(
      children: [
        AppTextField(
          controller: street,
          label: context.l10n.streetAddress,
          validator: required,
          enabled: enabled,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: city,
          label: context.l10n.city,
          validator: required,
          enabled: enabled,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: province,
          label: context.l10n.province,
          validator: required,
          enabled: enabled,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: zip,
          label: context.l10n.zipCode,
          keyboardType: TextInputType.number,
          enabled: enabled,
          // Optional — no validator.
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: lat,
          label: context.l10n.deliveryLatitude,
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          validator: (v) => coordinate(v, 23.5, 37.2),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: lng,
          label: context.l10n.deliveryLongitude,
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          validator: (v) => coordinate(v, 60.5, 77.9),
        ),
        Text(context.l10n.locationCoordinatesHelp),
      ],
    );
  }
}

class _OrderGroupCard extends StatelessWidget {
  const _OrderGroupCard({
    required this.group,
    required this.locale,
    this.quote,
  });
  final OrderQuote? quote;

  final FarmerCartGroup group;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.orderForFarmer(group.farmerName),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final item in group.items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.product.name}  ×${item.quantity}',
                      style: AppTextStyles.small,
                    ),
                  ),
                  Text(
                    context.l10n.currencyAmount(
                      formatCurrencyAmount(item.subtotal, locale),
                    ),
                    style: AppTextStyles.small,
                  ),
                ],
              ),
            ),
          const Divider(height: AppSpacing.lg, color: AppColors.surfaceMedium),
          _Row(
            label: context.l10n.subtotal,
            value: context.l10n.currencyAmount(
              formatCurrencyAmount(
                quote?.totalAmount ?? group.itemsSubtotal,
                locale,
              ),
            ),
          ),
          if (quote != null) ...[
            _Row(
              label: context.l10n.platformFeeWithPercent(
                quote!.platformFeePercent.toStringAsFixed(1),
              ),
              value: context.l10n.currencyAmount(
                formatCurrencyAmount(quote!.platformFeeAmount, locale),
              ),
            ),
            _Row(
              label: context.l10n.deliveryFee,
              value: context.l10n.currencyAmount(
                formatCurrencyAmount(quote!.deliveryFee, locale),
              ),
            ),
            Text(
              context.l10n.deliveryDistance(
                quote!.deliveryDistanceKm.toStringAsFixed(1),
              ),
              style: AppTextStyles.small,
            ),
            _Row(
              label: context.l10n.grandTotal,
              value: context.l10n.currencyAmount(
                formatCurrencyAmount(quote!.grandTotal, locale),
              ),
              emphasize: true,
            ),
          ] else
            Text(context.l10n.deliveryQuoteRequired),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryGreen,
          )
        : AppTextStyles.small.copyWith(color: AppColors.textMuted);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.groupCount,
    required this.isSubmitting,
    required this.onSubmit,
    required this.quoted,
  });

  final int groupCount;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final bool quoted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.surfaceMedium)),
      ),
      child: isSubmitting
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
            )
          : AppButton(
              label: quoted
                  ? context.l10n.placeOrderCount(groupCount)
                  : context.l10n.getDeliveryQuote,
              icon: Icons.lock_outline_rounded,
              expand: true,
              onPressed: onSubmit,
            ),
    );
  }
}
