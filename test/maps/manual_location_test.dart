import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/core/maps/location_picker_screen.dart';
import 'package:farm2fork_mobile/core/location/location_service.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import '../support/harness.dart';

class _Denied extends FakeLocationService {
  @override
  Future<GeoPoint> current() async =>
      throw const LocationException(LocationFailure.denied);
}

void main() {
  testWidgets('manual coordinates work with GPS denied and unavailable map', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      ProviderScope(
        overrides: [locationServiceProvider.overrideWithValue(_Denied())],
        child: const LocationPickerScreen(
          args: LocationPickerArgs(purpose: LocationPickerPurpose.farm),
        ),
      ),
    );
    await tester.tap(find.text('Enter coordinates'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Latitude'), '0');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Longitude'),
      '74.3587',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Confirm this spot'));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter valid coordinates inside Pakistan.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Latitude'),
      '31.5204',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Confirm this spot'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    final button = tester.widget<Widget>(find.text('Confirm this spot'));
    expect(button, isA<Text>());
    expect(tester.takeException(), isNull);
  });
}
