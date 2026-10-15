import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/providers/dispatch_controller.dart';

Future<bool?> showDeliveryAction(
  BuildContext context,
  Shipment shipment, {
  bool issue = false,
}) => showModalBottomSheet<bool>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  isDismissible: false,
  enableDrag: false,
  builder: (_) => _DeliveryAction(shipment: shipment, issue: issue),
);

class _DeliveryAction extends ConsumerStatefulWidget {
  const _DeliveryAction({required this.shipment, required this.issue});
  final Shipment shipment;
  final bool issue;
  @override
  ConsumerState<_DeliveryAction> createState() => _DeliveryActionState();
}

class _DeliveryActionState extends ConsumerState<_DeliveryAction> {
  final _code = TextEditingController();
  final _note = TextEditingController();
  String _reason = 'pickup_unavailable';
  bool _busy = false, _error = false;
  @override
  void initState() {
    super.initState();
    if (widget.shipment.status != ShipmentStatus.assigned) {
      _reason = 'recipient_unavailable';
    }
  }

  @override
  void dispose() {
    _code.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || (!widget.issue && _code.text.trim().isEmpty)) return;
    setState(() {
      _busy = true;
      _error = false;
    });
    try {
      final controller = ref.read(dispatchControllerProvider.notifier);
      if (widget.issue) {
        await controller.reportIssue(
          widget.shipment.id,
          _reason,
          _note.text.trim(),
        );
      } else {
        await controller.complete(
          widget.shipment.id,
          _code.text.trim(),
          _note.text.trim(),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } on Object {
      if (mounted && ref.read(dispatchControllerProvider).asData?.value.needsReconciliation == true) {
        final messenger = ScaffoldMessenger.of(context);
        final message = context.l10n.deliveryReconcileRequired;
        Navigator.pop(context, false);
        messenger.showSnackBar(SnackBar(content: Text(message)));
        return;
      }
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return PopScope(
      canPop: !_busy,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.issue ? l.reportDeliveryProblem : l.deliveryCodeTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                widget.issue
                    ? (widget.shipment.status == ShipmentStatus.assigned
                          ? l.problemBeforePickup
                          : l.problemInCustody)
                    : l.deliveryCodeHelp,
              ),
              const SizedBox(height: 16),
              if (widget.issue)
                DropdownButtonFormField<String>(
                  initialValue: _reason,
                  isExpanded: true,
                  items: [
                    for (final entry in {
                      'pickup_unavailable': l.pickupUnavailable,
                      'recipient_unavailable': l.recipientUnavailable,
                      'vehicle_issue': l.vehicleIssue,
                      'other': l.otherDeliveryProblem,
                    }.entries)
                      DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                  ],
                  onChanged: _busy
                      ? null
                      : (value) => setState(() => _reason = value!),
                )
              else
                TextField(
                  controller: _code,
                  enabled: !_busy,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  autofillHints: const [],
                  decoration: InputDecoration(labelText: l.deliveryCodeTitle),
                ),
              TextField(
                controller: _note,
                enabled: !_busy,
                maxLength: 1000,
                maxLines: 3,
                decoration: InputDecoration(labelText: l.optionalDeliveryNote),
              ),
              if (_error)
                Text(
                  widget.issue ? l.dispatchActionFailed : l.deliveryCodeError,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.issue
                            ? l.reportDeliveryProblem
                            : l.verifyDelivery,
                      ),
              ),
              TextButton(
                onPressed: _busy ? null : () => Navigator.pop(context),
                child: Text(l.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
