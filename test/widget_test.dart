import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:besufikad_bingo/branding.dart';
import 'package:besufikad_bingo/constant.dart';
import 'package:besufikad_bingo/main.dart';

/// Opens the cartela with [cardName] in the card slot at [slot].
Future<void> openCard(WidgetTester tester, int slot, int cardName) async {
  await tester.enterText(find.byType(TextField).at(slot), '$cardName');
  await tester.tap(find.text('Play').at(slot));
  await tester.pumpAndSettle();
}

/// The colour a cell is currently painted.
Color cellColour(WidgetTester tester, Finder cell) {
  final Container container = tester.widget<Container>(
    find.ancestor(of: cell, matching: find.byType(Container)).first,
  );
  return (container.decoration! as BoxDecoration).color!;
}

void main() {
  testWidgets('App shows Besufikad Bingo branding',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text(kAppName), findsWidgets);
    expect(find.text('Genius Bingo'), findsNothing);
    expect(find.text(kContactPhone), findsOneWidget);
  });

  testWidgets('Card selector offers up to $kMaxCards cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();

    expect(find.text('$kMaxCards cards'), findsWidgets);

    await tester.tap(find.text('$kMaxCards cards').last);
    await tester.pumpAndSettle();

    expect(find.text('Play'), findsNWidgets(kMaxCards));
  });

  testWidgets('Marking a number marks it on every card that shares it', (
    WidgetTester tester,
  ) async {
    // Two cartelas that both print the same number.
    late int first;
    late int second;
    late int shared;
    outer:
    for (final Map<String, dynamic> a in cards) {
      final Set<int> aNumbers = <int>{
        for (final String key in kColumns)
          ...(a[key] as List<dynamic>).cast<int>(),
      }..remove(0);
      for (final Map<String, dynamic> b in cards) {
        if (identical(a, b)) continue;
        for (final String key in kColumns) {
          for (final int number in (b[key] as List<dynamic>).cast<int>()) {
            if (number != 0 && aNumbers.contains(number)) {
              first = a['cardname'] as int;
              second = b['cardname'] as int;
              shared = number;
              break outer;
            }
          }
        }
      }
    }

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2 cards').last);
    await tester.pumpAndSettle();

    await openCard(tester, 0, first);
    await openCard(tester, 0, second);

    final Finder cells = find.text('$shared');
    expect(cells, findsNWidgets(2), reason: 'both cards print $shared');
    expect(cellColour(tester, cells.at(0)), kCellIdle);
    expect(cellColour(tester, cells.at(1)), kCellIdle);

    // Tapping the number on the first card must light it up on the second too.
    await tester.tap(cells.at(0));
    await tester.pumpAndSettle();

    for (int i = 0; i < 2; i++) {
      expect(
        cellColour(tester, find.text('$shared').at(i)),
        anyOf(kCellMarked, kCellWinning),
        reason: 'card $i should show $shared as marked',
      );
    }
  });
}
