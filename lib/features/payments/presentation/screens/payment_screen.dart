import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/features/payments/data/models/payment.dart';
import 'package:farm2fork_mobile/features/payments/presentation/providers/checkout_launcher.dart';
import 'package:farm2fork_mobile/features/payments/presentation/providers/payment_controller.dart';
import 'package:farm2fork_mobile/features/orders/presentation/providers/orders_controller.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.orderIds, this.returnResult});
  final List<String> orderIds;
  final String? returnResult;
  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen>
    with WidgetsBindingObserver {
  final _launchErrors = <String>{};
  bool _opening = false;
  bool _hasReadStatus = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refresh();
    });
  }

  @override
  void didUpdateWidget(PaymentScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderIds.join(',') != widget.orderIds.join(',') ||
        oldWidget.returnResult != widget.returnResult) {
      _hasReadStatus = false;
      _launchErrors.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _refresh();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) _refresh();
  }

  Future<void> _refresh() async {
    await ref.read(paymentControllerProvider.notifier).refresh(widget.orderIds);
    if (mounted) {
      setState(() => _hasReadStatus = true);
      ref.invalidate(ordersControllerProvider);
    }
  }

  Future<void> _pay(String orderId) async {
    if (_opening) return;
    setState(() {
      _opening = true;
      _launchErrors.remove(orderId);
    });
    try {
      final result = await ref.read(paymentControllerProvider.notifier).settle([
        orderId,
      ]);
      if (!mounted) return;
      final payment = result.payments[orderId];
      if (result.errorOrderIds.contains(orderId) || payment == null) return;
      if (payment.status != PaymentStatus.pending ||
          (ref.read(paymentSimulatorEnabledProvider) &&
              payment.gateway != 'safepay')) {
        ref.invalidate(ordersControllerProvider);
        return;
      }
      final uri = safepayCheckoutUri(payment.checkoutUrl);
      if (uri == null || !await ref.read(checkoutLauncherProvider)(uri)) {
        if (mounted) setState(() => _launchErrors.add(orderId));
      }
    } on Object {
      if (mounted) setState(() => _launchErrors.add(orderId));
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(paymentControllerProvider);
    final result = _hasReadStatus ? async.asData?.value : null;
    final busy = async.isLoading || _opening;
    final simulator = ref.watch(paymentSimulatorEnabledProvider);
    final allPaid =
        widget.orderIds.isNotEmpty &&
        result?.successfulOrderIds.length == widget.orderIds.length;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.paymentTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              allPaid
                  ? context.l10n.paymentComplete
                  : context.l10n.paymentPending,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              widget.returnResult == 'cancel'
                  ? context.l10n.paymentCheckoutClosed
                  : context.l10n.paymentServerStatus,
            ),
            if (widget.orderIds.isEmpty) Text(context.l10n.noDataFound),
            for (var index = 0; index < widget.orderIds.length; index++) ...[
              const SizedBox(height: 16),
              _orderCard(
                context,
                widget.orderIds[index],
                index,
                result,
                busy,
                simulator,
              ),
            ],
            const SizedBox(height: 20),
            AppButton(
              label: context.l10n.checkPaymentStatus,
              icon: Icons.refresh,
              isLoading: async.isLoading,
              onPressed: busy ? null : _refresh,
              expand: true,
            ),
            TextButton(
              onPressed: busy ? null : () => context.go('/buyer/orders'),
              child: Text(context.l10n.viewOrders),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderCard(
    BuildContext context,
    String orderId,
    int index,
    PaymentFlowResult? result,
    bool busy,
    bool simulator,
  ) {
    final payment = result?.payments[orderId];
    final status = switch (payment?.status) {
      PaymentStatus.success => context.l10n.paymentComplete,
      PaymentStatus.failed ||
      PaymentStatus.refunded => context.l10n.paymentFailed,
      PaymentStatus.pending || null => context.l10n.paymentPending,
    };
    final error =
        _launchErrors.contains(orderId) ||
        (result?.errorOrderIds.contains(orderId) ?? false);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.paymentOrderNumber(index + 1)),
          const SizedBox(height: 8),
          Text(status),
          if (error)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                context.l10n.paymentActionFailed,
                style: const TextStyle(color: AppColors.errorRed),
              ),
            ),
          if (payment?.status != PaymentStatus.success &&
              payment?.status != PaymentStatus.refunded) ...[
            const SizedBox(height: 12),
            AppButton(
              key: ValueKey('pay-$orderId'),
              label: simulator
                  ? context.l10n.completeTestPayment
                  : context.l10n.continueSafepay,
              onPressed: busy ? null : () => _pay(orderId),
              expand: true,
            ),
          ],
        ],
      ),
    );
  }
}
