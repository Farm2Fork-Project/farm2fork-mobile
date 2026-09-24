import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/features/farm_location/data/farm_location.dart';

String provinceLabel(BuildContext context, PakistanProvince province) =>
    switch (province) {
      PakistanProvince.punjab => context.l10n.provincePunjab,
      PakistanProvince.sindh => context.l10n.provinceSindh,
      PakistanProvince.khyberPakhtunkhwa => context.l10n.provinceKpk,
      PakistanProvince.balochistan => context.l10n.provinceBalochistan,
      PakistanProvince.gilgitBaltistan => context.l10n.provinceGilgitBaltistan,
      PakistanProvince.azadJammuKashmir => context.l10n.provinceAjk,
      PakistanProvince.islamabad => context.l10n.provinceIslamabad,
    };

class ProvinceDropdown extends StatelessWidget {
  const ProvinceDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final PakistanProvince? value;
  final ValueChanged<PakistanProvince?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PakistanProvince>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: context.l10n.farmProvince),
      hint: Text(context.l10n.farmProvinceHint),
      items: [
        for (final province in PakistanProvince.values)
          DropdownMenuItem(
            value: province,
            child: Text(provinceLabel(context, province)),
          ),
      ],
      validator: (v) => v == null ? context.l10n.fieldRequired : null,
      onChanged: onChanged,
    );
  }
}
