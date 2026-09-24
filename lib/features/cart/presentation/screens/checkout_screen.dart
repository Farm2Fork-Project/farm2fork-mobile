import 'package:flutter/material.dart';
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
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/maps/location_picker_screen.dart';
import 'package:farm2fork_mobile/core/maps/location_pin_field.dart';
import 'package:farm2fork_mobile/features/farm_location/data/farm_location.dart';
import 'package:farm2fork_mobile/features/farm_location/presentation/province_dropdown.dart';
import 'package:farm2fork_mobile/features/orders/data/models/order.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/orders_repository_provider.dart';

/// Buyer checkout: enter a shipping address and pin the drop-off on the map,
/// review the per-farmer summary with its server-quoted delivery fee, and
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
  final _zip = TextEditingController();
  PakistanProvince? _province;
  GeoPoint? _dropoff;

  /// Server quote per farmer group, refreshed whenever the pin changes.
  final Map<String, AsyncValue<OrderQuote>> _quotes = {};
  int _quoteGeneration = 0;

  @override
  void dispose() {
    _street.dispose();
    _city.dispose();
    _zip.dispose();
    super.dispose();
  }

  OrderAddress _address() => OrderAddress(
    street: _street.text.trim(),
    city: _city.text.trim(),
    province: _province?.wire ?? '',
    zip: _zip.text.trim().isEmpty ? null : _zip.text.trim(),
    lat: _dropoff?.lat,
    lng: _dropoff?.lng,
  );

  Future<void> _refreshQuotes(List<FarmerCartGroup> groups) async {
    if (_dropoff == null) return;
    final generation = ++_quoteGeneration;
    final repo = ref.read(ordersRepositoryProvider);
    setState(() {
      for (final group in groups) {
        _quotes[group.farmerId] = const AsyncLoading();
      }
    });
    await Future.wait(
      groups.map((group) async {
        final result = await AsyncValue.guard(
          () => repo.quoteOrder(
            items: [
              for (final item in group.items)
                (productId: item.product.id, quantity: item.quantity),
            ],
            shippingAddress: _address(),
          ),
        );
        // A newer pin superseded this request.
        if (!mounted || generation != _quoteGeneration) return;
        setState(() => _quotes[group.farmerId] = result);
      }),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final address = _address();

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
    final isSubmitting = ref.watch(checkoutControllerProvider).isLoading;
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(title: context.l10n.shippingAddress),
                            const SizedBox(height: AppSpacing.sm),
                            _AddressForm(
                              street: _street,
                              city: _city,
                              province: _province,
                              onProvinceChanged: (value) =>
                                  setState(() => _province = value),
                              zip: _zip,
                              enabled: !isSubmitting,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            LocationPinField(
                              purpose: LocationPickerPurpose.dropoff,
                              initialValue: _dropoff,
                              onChanged: (pin) {
                                setState(() => _dropoff = pin);
                                _refreshQuotes(groups);
                              },
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
                                quote: _quotes[group.farmerId],
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  _SubmitBar(
                    groupCount: groups.length,
                    isSubmitting: isSubmitting,
                    onSubmit: _submit,
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
    required this.onProvinceChanged,
    required this.zip,
    required this.enabled,
  });

  final TextEditingController street;
  final TextEditingController city;
  final PakistanProvince? province;
  final ValueChanged<PakistanProvince?> onProvinceChanged;
  final TextEditingController zip;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? context.l10n.fieldRequired : null;

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
        ProvinceDropdown(
          value: province,
          onChanged: enabled ? onProvinceChanged : (_) {},
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: zip,
          label: context.l10n.zipCode,
          keyboardType: TextInputType.number,
          enabled: enabled,
          // Optional — no validator.
        ),
      ],
    );
  }
}

class _OrderGroupCard extends StatelessWidget {
  const _OrderGroupCard({
    required this.group,
    required this.locale,
    required this.quote,
  });

  final FarmerCartGroup group;
  final Locale locale;

  /// Null until the drop-off is pinned.
  final AsyncValue<OrderQuote>? quote;

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
              formatCurrencyAmount(group.itemsSubtotal, locale),
            ),
          ),
          _Row(
            label: context.l10n.platformFeeWithPercent(
              group.platformFeePercent.toStringAsFixed(0),
            ),
            value: context.l10n.currencyAmount(
              formatCurrencyAmount(group.platformFee, locale),
            ),
          ),
          ..._deliveryRows(context),
          const SizedBox(height: AppSpacing.xs),
          _Row(
            label: context.l10n.grandTotal,
            value: context.l10n.currencyAmount(
              formatCurrencyAmount(
                quote?.asData?.value.grandTotal ?? group.grandTotal,
                locale,
              ),
            ),
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

extension on _OrderGroupCard {
  List<Widget> _deliveryRows(BuildContext context) {
    final note = AppTextStyles.small.copyWith(color: AppColors.textMuted);
    final q = quote;
    if (q == null) {
      return [Text(context.l10n.deliveryFeePinFirst, style: note)];
    }
    return q.when(
      loading: () => [Text(context.l10n.deliveryFeeCalculating, style: note)],
      error: (_, _) => [
        Text(
          context.l10n.deliveryFeeUnavailable,
          style: AppTextStyles.small.copyWith(color: AppColors.errorRed),
        ),
      ],
      data: (value) => [
        _Row(
          label: context.l10n.deliveryFeeWithDistance(
            value.deliveryDistanceKm.toStringAsFixed(1),
          ),
          value: context.l10n.currencyAmount(
            formatCurrencyAmount(value.deliveryFee, locale),
          ),
        ),
      ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: AppSpacing.sm),
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
  });

  final int groupCount;
  final bool isSubmitting;
  final VoidCallback onSubmit;

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
              label: context.l10n.placeOrderCount(groupCount),
              icon: Icons.lock_outline_rounded,
              expand: true,
              onPressed: onSubmit,
            ),
    );
  }
}
