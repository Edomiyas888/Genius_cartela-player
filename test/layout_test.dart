import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:besufikad_bingo/branding.dart';
import 'package:besufikad_bingo/main.dart';

/// Screen sizes the board has to survive, in logical pixels.
const Map<String, Size> screens = <String, Size>{
  'small phone': Size(320, 568),
  'phone': Size(411, 731),
  'tablet': Size(834, 1112),
};

Future<void> selectCardCount(WidgetTester tester, int count) async {
  await tester.tap(find.byType(DropdownButton<int>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('$count cards').last);
  await tester.pumpAndSettle();
}

void main() {
  for (final MapEntry<String, Size> screen in screens.entries) {
    for (final int count in <int>[2, 4, 6, 8, kMaxCards]) {
      testWidgets('$count cards lay out on a ${screen.key} without overflow', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = screen.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await selectCardCount(tester, count);
        expect(find.text('Play'), findsNWidgets(count));

        // Fill every slot with a real cartela and render the boards. The
        // board never scrolls, so every slot is already on screen.
        for (int slot = 0; slot < count; slot++) {
          await tester.enterText(find.byType(TextField).first, '${slot + 1}');
          await tester.pumpAndSettle();
          await tester.tap(find.text('Play').first, warnIfMissed: false);
          await tester.pumpAndSettle();
        }

        expect(find.text('Back'), findsNWidgets(count));
        // A RenderFlex overflow is reported as a test exception, so reaching
        // here with none pending means every board fitted its tile.
        expect(tester.takeException(), isNull);
      });
    }
  }
}
