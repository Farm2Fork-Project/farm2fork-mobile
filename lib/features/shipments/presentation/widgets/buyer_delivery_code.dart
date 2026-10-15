import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository_provider.dart';

class BuyerDeliveryCode extends ConsumerStatefulWidget {
  const BuyerDeliveryCode({super.key, required this.shipmentId});
  final String shipmentId;
  @override
  ConsumerState<BuyerDeliveryCode> createState() => _BuyerDeliveryCodeState();
}

class _BuyerDeliveryCodeState extends ConsumerState<BuyerDeliveryCode> {
  String? _code;
  bool _busy = false, _failed = false;
  Future<void> _load({bool reissue = false}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failed = false;
      if (reissue) _code = null;
    });
    try {
      final code = await ref
          .read(shipmentsRepositoryProvider)
          .getDeliveryCode(widget.shipmentId, reissue: reissue);
      if (mounted) setState(() => _code = code);
    } on Object {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.deliveryCodeTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(l.buyerCodeHelp),
          if (_code != null)
            SelectableText(
              _code!,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          if (_failed) Text(l.dispatchActionFailed),
          if (_busy) const Center(child: CircularProgressIndicator()),
          FilledButton(
            onPressed: _busy ? null : _load,
            child: Text(_failed ? l.retry : l.revealDeliveryCode),
          ),
          if (_code != null)
            TextButton(
              onPressed: _busy ? null : () => _load(reissue: true),
              child: Text(l.reissueDeliveryCode),
            ),
        ],
      ),
    );
  }
}
