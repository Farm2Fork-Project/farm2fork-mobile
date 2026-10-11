import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/features/shipments/data/services/transporter_dispatch_service.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/screens/transporter_availability.dart';

class _Dispatch extends TransporterDispatchService {
  _Dispatch() : super(Dio());
  bool online = false, fail = false;
  final calls = <Map<String, Object?>>[];
  @override
  Future<TransporterStatus> getStatus() async =>
      TransporterStatus(online: online, locationFresh: online, radiusKm: 20);
  @override
  Future<TransporterStatus> setAvailability(
    bool value, {
    double? lat,
    double? lng,
  }) async {
    calls.add({'online': value, if (value) 'lat': lat, if (value) 'lng': lng});
    if (fail) throw StateError('offline');
    online = value;
    return getStatus();
  }

  @override
  Future<void> updateLocation(double lat, double lng) async {
    calls.add({'lat': lat, 'lng': lng});
  }
}

Finder field(String label) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.labelText == label,
);
Future<void> enter(WidgetTester tester, String label, String value) async {
  await tester.ensureVisible(field(label));
  await tester.enterText(field(label), value);
  await tester.pump();
}

void main() {
  for (final language in ['en', 'ur']) {
    testWidgets(
      '$language validates current pins, updates online location and allows offline without coordinates',
      (tester) async {
        final service = _Dispatch();
        var refreshed = 0;
        final locale = Locale(language);
        final strings = lookupAppLocalizations(locale);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              transporterDispatchServiceProvider.overrideWithValue(service),
            ],
            child: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (_, _) => MaterialApp(
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: TransporterAvailability(
                      revision: '',
                      onRefresh: () async {
                        refreshed++;
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await enter(tester, strings.dispatchLatitude, '0');
        await enter(tester, strings.dispatchLongitude, '74.35');
        await tester.ensureVisible(find.text(strings.dispatchGoOnline));
        await tester.tap(find.text(strings.dispatchGoOnline));
        await tester.pumpAndSettle();
        expect(service.calls, isEmpty);
        await enter(tester, strings.dispatchLatitude, '31.52');
        service.fail = true;
        await tester.ensureVisible(find.text(strings.dispatchGoOnline));
        await tester.tap(find.text(strings.dispatchGoOnline));
        await tester.pumpAndSettle();
        expect(find.text(strings.dispatchError), findsOneWidget);
        expect(service.online, false);
        service.fail = false;
        await tester.tap(find.text(strings.dispatchGoOnline));
        await tester.pumpAndSettle();
        expect(service.calls.last, {
          'online': true,
          'lat': 31.52,
          'lng': 74.35,
        });
        await enter(tester, strings.dispatchLatitude, '31.53');
        await tester.ensureVisible(find.text(strings.dispatchUpdateLocation));
        await tester.tap(find.text(strings.dispatchUpdateLocation));
        await tester.pumpAndSettle();
        expect(service.calls.last, {'lat': 31.53, 'lng': 74.35});
        await enter(tester, strings.dispatchLatitude, '');
        await tester.ensureVisible(find.text(strings.dispatchGoOffline));
        await tester.tap(find.text(strings.dispatchGoOffline));
        await tester.pumpAndSettle();
        expect(service.calls.last, {'online': false});
        expect(refreshed, 3);
      },
    );
  }
}
