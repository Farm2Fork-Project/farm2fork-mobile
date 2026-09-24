import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/maps/location_picker_screen.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';

/// Form field showing whether a map pin is set, opening the picker on tap.
class LocationPinField extends FormField<GeoPoint> {
  LocationPinField({
    super.key,
    required LocationPickerPurpose purpose,
    super.initialValue,
    required ValueChanged<GeoPoint> onChanged,
    bool required = true,
  }) : super(
         validator: (value) {
           if (!required) return null;
           // Localised in the builder; any non-null marker triggers the error.
           return value == null ? 'required' : null;
         },
         builder: (field) {
           final context = field.context;
           final l10n = context.l10n;
           final value = field.value;
           Future<void> pick() async {
             final picked = await context.push<GeoPoint>(
               LocationPickerScreen.route,
               extra: LocationPickerArgs(initial: value, purpose: purpose),
             );
             if (picked == null) return;
             field.didChange(picked);
             onChanged(picked);
           }

           final hasError = field.hasError;
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               InkWell(
                 onTap: pick,
                 borderRadius: BorderRadius.circular(12),
                 child: Container(
                   constraints: const BoxConstraints(minHeight: 56),
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
                     color: value == null
                         ? AppColors.white
                         : AppColors.primaryGreen.withValues(alpha: 0.06),
                   ),
                   child: Row(
                     children: [
                       Icon(
                         value == null
                             ? Icons.add_location_alt_rounded
                             : Icons.where_to_vote_rounded,
                         color: value == null
                             ? AppColors.textMuted
                             : AppColors.primaryGreen,
                       ),
                       const SizedBox(width: AppSpacing.sm),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               value == null
                                   ? (purpose == LocationPickerPurpose.farm
                                         ? l10n.pinFarmOnMap
                                         : l10n.pinDropoffOnMap)
                                   : l10n.pinSet,
                               style: AppTextStyles.body.copyWith(
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                             if (value != null)
                               Text(
                                 value.toString(),
                                 textDirection: TextDirection.ltr,
                                 style: AppTextStyles.small.copyWith(
                                   color: AppColors.textMuted,
                                 ),
                               ),
                           ],
                         ),
                       ),
                       Text(
                         value == null ? l10n.pinOpenMap : l10n.pinChange,
                         style: AppTextStyles.small.copyWith(
                           color: AppColors.primaryGreen,
                           fontWeight: FontWeight.w600,
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
               if (hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 6, left: AppSpacing.md),
                   child: Text(
                     l10n.pinRequired,
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
