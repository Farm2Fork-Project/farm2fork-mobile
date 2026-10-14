import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_text_field.dart';
import 'package:farm2fork_mobile/features/shipments/data/services/transporter_dispatch_service.dart';

class TransporterAvailability extends ConsumerStatefulWidget {
  const TransporterAvailability({
    super.key,
    required this.onRefresh,
    required this.revision,
  });
  final Future<void> Function() onRefresh;
  final String revision;
  @override
  ConsumerState<TransporterAvailability> createState() =>
      _TransporterAvailabilityState();
}

class _TransporterAvailabilityState
    extends ConsumerState<TransporterAvailability> {
  final _form = GlobalKey<FormState>();
  final _lat = TextEditingController(), _lng = TextEditingController();
  TransporterStatus? _status;
  bool _busy = false, _error = false;
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void didUpdateWidget(TransporterAvailability old) {
    super.didUpdateWidget(old);
    if (old.revision != widget.revision && !_busy) Future.microtask(_load);
  }

  @override
  void dispose() {
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final status = await ref
          .read(transporterDispatchServiceProvider)
          .getStatus();
      if (mounted) {
        setState(() {
          _status = status;
          _error = false;
        });
      }
    } on Object {
      if (mounted) setState(() => _error = true);
    }
  }

  Future<void> _action(String action) async {
    if (_busy) return;
    if (action == 'location' &&
        (!(_form.currentState?.validate() ?? false) || _status == null)) {
      return;
    }
    setState(() {
      _busy = true;
      _error = false;
    });
    try {
      final service = ref.read(transporterDispatchServiceProvider);
      TransporterStatus status;
      if (action == 'offline') {
        status = await service.setAvailability(false);
      } else if (action == 'location') {
        final lat = double.parse(_lat.text), lng = double.parse(_lng.text);
        if (_status!.online) {
          await service.updateLocation(lat, lng);
          status = await service.getStatus();
        } else {
          status = await service.setAvailability(true, lat: lat, lng: lng);
        }
      } else {
        status = await service.getStatus();
      }
      if (mounted) setState(() => _status = status);
      await widget.onRefresh();
    } on Object {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? pin(String? value, double min, double max) {
      final n = double.tryParse(value ?? '');
      return n == null || !n.isFinite || n < min || n > max
          ? context.l10n.locationInvalid
          : null;
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.dispatchTitle),
          Text(
            _status == null
                ? context.l10n.dispatchLoading
                : _status!.online
                ? context.l10n.dispatchOnline
                : context.l10n.dispatchOffline,
          ),
          if (_status != null) ...[
            Text(
              _status!.locationFresh
                  ? context.l10n.dispatchFresh
                  : context.l10n.dispatchStale,
            ),
            Text('${context.l10n.dispatchRadius}: ${_status!.radiusKm} km'),
            if (_status!.activeShipmentId != null)
              Text(context.l10n.dispatchActive),
            if (_status!.lastLocationAt != null)
              Text(
                '${context.l10n.dispatchUpdated}: ${_status!.lastLocationAt!.toLocal()}',
              ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(context.l10n.dispatchHelp),
          Form(
            key: _form,
            child: Column(
              children: [
                AppTextField(
                  controller: _lat,
                  label: context.l10n.dispatchLatitude,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  enabled: !_busy && _status != null,
                  validator: (v) => pin(v, 23.5, 37.2),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _lng,
                  label: context.l10n.dispatchLongitude,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  enabled: !_busy && _status != null,
                  validator: (v) => pin(v, 60.5, 77.9),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: _status?.online == true
                ? context.l10n.dispatchUpdateLocation
                : context.l10n.dispatchGoOnline,
            isLoading: _busy,
            onPressed: _busy || _status == null
                ? null
                : () => _action('location'),
          ),
          if (_status?.online == true)
            TextButton(
              onPressed: _busy ? null : () => _action('offline'),
              child: Text(context.l10n.dispatchGoOffline),
            ),
          TextButton(
            onPressed: _busy ? null : () => _action('refresh'),
            child: Text(context.l10n.dispatchRefresh),
          ),
          if (_error) Text(context.l10n.dispatchError),
        ],
      ),
    );
  }
}
