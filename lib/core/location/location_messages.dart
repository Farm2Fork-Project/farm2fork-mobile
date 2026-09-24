import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/location/location_service.dart';

String locationFailureMessage(BuildContext context, LocationFailure failure) =>
    switch (failure) {
      LocationFailure.serviceDisabled => context.l10n.locationServiceDisabled,
      LocationFailure.denied => context.l10n.locationPermissionDenied,
      LocationFailure.deniedForever =>
        context.l10n.locationPermissionDeniedForever,
      LocationFailure.unavailable => context.l10n.locationUnavailable,
    };

/// Snackbar with a Settings action when the fix is in the OS settings.
void showLocationFailure(
  BuildContext context,
  LocationService service,
  LocationFailure failure,
) {
  final needsSettings =
      failure == LocationFailure.serviceDisabled ||
      failure == LocationFailure.deniedForever;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(locationFailureMessage(context, failure)),
      action: needsSettings
          ? SnackBarAction(
              label: context.l10n.openSettings,
              onPressed: () => service.openSettingsFor(failure),
            )
          : null,
    ),
  );
}
