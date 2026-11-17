import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/maps/location_picker_screen.dart';
import 'package:farm2fork_mobile/core/maps/location_pin_field.dart';
import 'package:farm2fork_mobile/core/widgets/app_text_field.dart';
import 'package:farm2fork_mobile/features/farm_location/data/farm_location.dart';
import 'package:farm2fork_mobile/features/farm_location/presentation/city_picker.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/features/listings/data/services/farm_location_service.dart';

class FarmLocationScreen extends ConsumerStatefulWidget {
  const FarmLocationScreen({super.key});
  @override
  ConsumerState<FarmLocationScreen> createState() => _FarmLocationScreenState();
}

class _FarmLocationScreenState extends ConsumerState<FarmLocationScreen> {
  final _form = GlobalKey<FormState>();
  final _address = TextEditingController();
  String _city = '';
  PakistanProvince? _province;
  GeoPoint? _pin;
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
      _city = location['city'] as String? ?? '';
      _pin = GeoPoint.tryParse(location);
      _province = PakistanProvince.fromWire(location['province'] as String?);
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
        'city': _city.trim(),
        'province': _province?.wire,
        'lat': _pin!.lat,
        'lng': _pin!.lng,
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
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? required(String? value) => value == null || value.trim().isEmpty
        ? context.l10n.fieldRequired
        : null;

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
                  CityPickerField(
                    // Re-created once the saved location has loaded.
                    key: ValueKey('$_loaded$_city$_province'),
                    city: _city,
                    province: _province,
                    enabled: !_busy && _loaded,
                    onChanged: (choice) => setState(() {
                      _city = choice.city;
                      _province = choice.province;
                      _saved = false;
                    }),
                  ),
                  const SizedBox(height: 16),
                  AbsorbPointer(
                    absorbing: _busy || !_loaded,
                    child: LocationPinField(
                      key: ValueKey('pin$_loaded${_pin?.lat}'),
                      purpose: LocationPickerPurpose.farm,
                      initialValue: _pin,
                      city: _city,
                      province: _province?.wire,
                      onChanged: (pin) => setState(() {
                        _pin = pin;
                        _saved = false;
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _address,
                    label: context.l10n.streetAddress,
                    enabled: !_busy && _loaded,
                    validator: required,
                  ),
                ],
              ),
            ),
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
