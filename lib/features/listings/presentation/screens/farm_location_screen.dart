import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/widgets/app_text_field.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/features/listings/data/services/farm_location_service.dart';

const _provinces = [
  'Punjab',
  'Sindh',
  'Khyber Pakhtunkhwa',
  'Balochistan',
  'Gilgit-Baltistan',
  'Azad Jammu and Kashmir',
  'Islamabad Capital Territory',
];

class FarmLocationScreen extends ConsumerStatefulWidget {
  const FarmLocationScreen({super.key});
  @override
  ConsumerState<FarmLocationScreen> createState() => _FarmLocationScreenState();
}

class _FarmLocationScreenState extends ConsumerState<FarmLocationScreen> {
  final _form = GlobalKey<FormState>();
  final _address = TextEditingController(),
      _city = TextEditingController(),
      _lat = TextEditingController(),
      _lng = TextEditingController();
  String? _province;
  bool _busy = true, _loaded = false, _error = false, _saved = false;
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = false;
    });
    try {
      final location = await ref.read(farmLocationServiceProvider).get();
      if (!mounted) return;
      _address.text = location['address'] as String? ?? '';
      _city.text = location['city'] as String? ?? '';
      _lat.text = location['lat']?.toString() ?? '';
      _lng.text = location['lng']?.toString() ?? '';
      final province = location['province'] as String?;
      _province = _provinces.contains(province) ? province : null;
      setState(() => _loaded = true);
    } on Object {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    if (_busy || !_loaded || !(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = false;
      _saved = false;
    });
    try {
      final response = await ref.read(farmLocationServiceProvider).save({
        'address': _address.text.trim(),
        'city': _city.text.trim(),
        'province': _province,
        'lat': double.parse(_lat.text),
        'lng': double.parse(_lng.text),
      });
      if (response['complete'] != true) {
        throw const FormatException('Incomplete location');
      }
      if (mounted) setState(() => _saved = true);
    } on Object {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    for (final controller in [_address, _city, _lat, _lng]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? required(String? value) => value == null || value.trim().isEmpty
        ? context.l10n.fieldRequired
        : null;
    String? coordinate(String? value, double min, double max) {
      final n = double.tryParse(value ?? '');
      return n == null || !n.isFinite || n < min || n > max
          ? context.l10n.locationInvalid
          : null;
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.farmPickupLocation)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(context.l10n.farmPickupHelp),
            Form(
              key: _form,
              onChanged: () {
                if (_saved) setState(() => _saved = false);
              },
              child: Column(
                children: [
                  AppTextField(
                    controller: _address,
                    label: context.l10n.streetAddress,
                    enabled: !_busy && _loaded,
                    validator: required,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _city,
                    label: context.l10n.city,
                    enabled: !_busy && _loaded,
                    validator: required,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_province),
                    initialValue: _province,
                    decoration: InputDecoration(
                      labelText: context.l10n.province,
                    ),
                    items: _provinces
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: _busy || !_loaded
                        ? null
                        : (value) => setState(() {
                            _province = value;
                            _saved = false;
                          }),
                    validator: required,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _lat,
                    label: context.l10n.locationLatitude,
                    enabled: !_busy && _loaded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (v) => coordinate(v, 23.5, 37.2),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _lng,
                    label: context.l10n.locationLongitude,
                    enabled: !_busy && _loaded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (v) => coordinate(v, 60.5, 77.9),
                  ),
                ],
              ),
            ),
            Text(context.l10n.locationCoordinatesHelp),
            if (_error) Text(context.l10n.farmPickupFailed),
            if (_saved) Text(context.l10n.farmPickupSaved),
            const SizedBox(height: 16),
            AppButton(
              label: context.l10n.farmPickupSave,
              isLoading: _busy,
              onPressed: _busy || !_loaded ? null : _save,
              expand: true,
            ),
            if (!_loaded && !_busy)
              TextButton(onPressed: _load, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }
}
