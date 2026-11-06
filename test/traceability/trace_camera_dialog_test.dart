import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/features/traceability/presentation/widgets/trace_camera.dart';

void main() {
  for (final dismissal in ['close', 'back', 'barrier']) {
    testWidgets('late capture after $dismissal cannot pop underlying route', (
      tester,
    ) async {
      late ValueChanged<String> detect;
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          home: const Scaffold(body: Text('home')),
        ),
      );
      key.currentState!.push(
        MaterialPageRoute<void>(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showTraceCamera(
                context,
                cameraBuilder: (onScan) {
                  detect = onScan;
                  return const SizedBox.expand();
                },
              ),
              child: const Text('open scanner'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('open scanner'));
      await tester.pumpAndSettle();
      if (dismissal == 'close') {
        await tester.tap(find.byIcon(Icons.close));
      } else if (dismissal == 'back') {
        key.currentState!.pop();
      } else {
        await tester.tapAt(const Offset(5, 5));
      }
      // Intentionally fire before pumping the dialog's exit animation.
      detect('https://farm2fork.tech/trace/orders/6a2fe77bb77795516febc287');
      await tester.pumpAndSettle();
      expect(find.text('open scanner'), findsOneWidget);
      expect(key.currentState!.canPop(), isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
