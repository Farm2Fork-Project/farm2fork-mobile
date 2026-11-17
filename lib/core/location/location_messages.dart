import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/location/location_service.dart';

String locationFailureMessage(BuildContext context, LocationFailure failure) =>
    switch (failure) {
      LocationFailure.serviceDisabled => context.l10n.locationServiceDisabled,
      LocationFailure.denied => context.l10n.locationPermissionDenied,
      LocationFailure.deniedForever =>
        context.l10n.locationPermissionDeniedForever,
      LocationFailure.timeout => context.l10n.locationTimeout,
      LocationFailure.lowAccuracy => context.l10n.locationLowAccuracy,
      LocationFailure.unavailable => context.l10n.locationUnavailable,
    };

/// Snackbar that explains the problem in plain words. It offers Settings when
/// the fix lives there, or "Try again" when asking again can work; the map pin
/// stays draggable either way, so the user is never stuck.
void showLocationFailure(
  BuildContext context,
  LocationService service,
  LocationFailure failure, {
  VoidCallback? onRetry,
}) {
  final needsSettings =
      failure == LocationFailure.serviceDisabled ||
      failure == LocationFailure.deniedForever;
  final canRetry =
      onRetry != null &&
      (failure == LocationFailure.denied ||
          failure == LocationFailure.timeout ||
          failure == LocationFailure.unavailable);
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 8),
      persist: false,
      content: Text(locationFailureMessage(context, failure)),
      action: needsSettings
          ? SnackBarAction(
              label: context.l10n.openSettings,
              onPressed: () => service.openSettingsFor(failure),
            )
          : canRetry
          ? SnackBarAction(label: context.l10n.retry, onPressed: onRetry)
          : null,
    ),
  );
}
