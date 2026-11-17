import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/location/pakistan_locations.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
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

/// Label for a dataset province name, falling back to the raw name.
String provinceNameLabel(BuildContext context, String wire) {
  final province = PakistanProvince.fromWire(wire);
  return province == null ? wire : provinceLabel(context, province);
}

/// A province + city picked from the bundled list. [centre] is null only for
/// a city saved before the picker existed that is not in the list.
class CityChoice {
  const CityChoice({required this.province, required this.city, this.centre});

  final PakistanProvince province;
  final String city;
  final GeoPoint? centre;

  @override
  bool operator ==(Object other) =>
      other is CityChoice && other.province == province && other.city == city;

  @override
  int get hashCode => Object.hash(province, city);
}

/// Opens the Province -> City sheet. Returns null when dismissed.
Future<CityChoice?> showCityPicker(
  BuildContext context, {
  PakistanProvince? province,
}) => showModalBottomSheet<CityChoice>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  backgroundColor: AppColors.white,
  builder: (_) => FractionallySizedBox(
    heightFactor: 0.9,
    child: CityPickerSheet(initialProvince: province),
  ),
);

/// Step 1 lists provinces, step 2 their cities; the search box filters either
/// step, and on step 1 it searches every city so a user who knows only the
/// city name still gets there.
class CityPickerSheet extends ConsumerStatefulWidget {
  const CityPickerSheet({super.key, this.initialProvince});

  final PakistanProvince? initialProvince;

  @override
  ConsumerState<CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends ConsumerState<CityPickerSheet> {
  late PakistanProvince? _province = widget.initialProvince;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _setProvince(PakistanProvince? province) => setState(() {
    _province = province;
    _search.clear();
  });

  void _choose(PakistanCity city) {
    final province = PakistanProvince.fromWire(city.province);
    if (province == null) return;
    Navigator.of(
      context,
    ).pop(CityChoice(province: province, city: city.name, centre: city.centre));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locations = ref.watch(pakistanLocationsProvider);
    final query = _search.text.trim().toLowerCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.sm,
            0,
            AppSpacing.pagePadding,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              if (_province != null)
                IconButton(
                  tooltip: l10n.cityPickerChangeProvince,
                  iconSize: 28,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  onPressed: () => _setProvince(null),
                  icon: const BackButtonIcon(),
                )
              else
                const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  _province == null
                      ? l10n.cityPickerChooseProvince
                      : provinceLabel(context, _province!),
                  style: AppTextStyles.h3,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
          ),
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.cityPickerSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.cityPickerClearSearch,
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => setState(_search.clear),
                    ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: locations.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(child: Text(l10n.cityPickerLoadFailed)),
            data: (data) => _body(context, data, query),
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, PakistanLocations data, String query) {
    final l10n = context.l10n;
    if (_province == null && query.isEmpty) {
      return ListView(
        children: [
          for (final province in PakistanProvince.values)
            _Row(
              title: provinceLabel(context, province),
              subtitle: l10n.cityPickerCityCount(
                data.citiesOf(province.wire).length,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _setProvince(province),
            ),
        ],
      );
    }
    final pool = _province == null
        ? [for (final p in data.provinces) ...p.cities]
        : data.citiesOf(_province!.wire);
    final matches = [
      for (final c in pool)
        if (query.isEmpty || c.name.toLowerCase().contains(query)) c,
    ];
    if (matches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            l10n.cityPickerNoResults,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
        ),
      );
    }
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: matches.length,
      itemBuilder: (context, i) {
        final city = matches[i];
        return _Row(
          title: city.name,
          subtitle: _province == null
              ? provinceNameLabel(context, city.province)
              : null,
          onTap: () => _choose(city),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyles.body),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    ),
  );
}

/// Form field that shows "City, Province" and opens [showCityPicker]. Replaces
/// the free-text city box and the province dropdown.
class CityPickerField extends FormField<CityChoice> {
  CityPickerField({
    super.key,
    String? city,
    PakistanProvince? province,
    required ValueChanged<CityChoice> onChanged,
    super.enabled,
  }) : super(
         initialValue: (province != null && (city?.trim().isNotEmpty ?? false))
             ? CityChoice(province: province, city: city!.trim())
             : null,
         validator: (value) => value == null ? 'required' : null,
         builder: (field) {
           final context = field.context;
           final l10n = context.l10n;
           final value = field.value;
           Future<void> pick() async {
             final choice = await showCityPicker(
               context,
               province: value?.province,
             );
             if (choice == null) return;
             field.didChange(choice);
             onChanged(choice);
           }

           final hasError = field.hasError;
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               InkWell(
                 onTap: field.widget.enabled ? pick : null,
                 borderRadius: BorderRadius.circular(12),
                 child: Container(
                   constraints: const BoxConstraints(minHeight: 60),
                   padding: const EdgeInsets.symmetric(
                     horizontal: AppSpacing.md,
                     vertical: AppSpacing.sm,
                   ),
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(
                       color: hasError
                           ? AppColors.errorRed
                           : AppColors.surfaceMedium,
                     ),
                     color: AppColors.white,
                   ),
                   child: Row(
                     children: [
                       const Icon(
                         Icons.location_city_rounded,
                         color: AppColors.primaryGreen,
                       ),
                       const SizedBox(width: AppSpacing.sm),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               l10n.city,
                               style: AppTextStyles.small.copyWith(
                                 color: AppColors.textMuted,
                               ),
                             ),
                             Text(
                               value == null
                                   ? l10n.cityPickerFieldHint
                                   : '${value.city}, '
                                         '${provinceLabel(context, value.province)}',
                               style: AppTextStyles.body.copyWith(
                                 fontWeight: FontWeight.w600,
                                 color: value == null
                                     ? AppColors.textMuted
                                     : AppColors.textDark,
                               ),
                             ),
                           ],
                         ),
                       ),
                       const Icon(
                         Icons.expand_more_rounded,
                         color: AppColors.textMuted,
                       ),
                     ],
                   ),
                 ),
               ),
               if (hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 6, left: AppSpacing.md),
                   child: Text(
                     l10n.cityPickerRequired,
                     style: AppTextStyles.small.copyWith(
                       color: AppColors.errorRed,
                     ),
                   ),
                 ),
             ],
           );
         },
       );
}
