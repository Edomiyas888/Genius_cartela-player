import 'package:flutter_test/flutter_test.dart';

import 'package:GeniusBingo/main.dart';

void main() {
  testWidgets('App loads with Genius Bingo branding', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Enter a Number'), findsOneWidget);
    expect(find.text('Genius Bingo'), findsNothing);
  });
}
