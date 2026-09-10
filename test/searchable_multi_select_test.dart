import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:searchable_spinner_multiselect/searchable_spinner_multiselect.dart';

void main() {
  final items = List.generate(6, (i) => 'Item ${i + 1}');

  Widget app({
    List<String> values = const [],
    int? maxSelection,
    ValueChanged<List<String>>? onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SearchableMultiSelect<String>(
          items: items,
          values: values,
          itemLabel: (e) => e,
          maxSelection: maxSelection,
          onChanged: onChanged ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('opens multi-select dialog', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.text('Select items'));
    await tester.pumpAndSettle();

    expect(find.text('Select All'), findsOneWidget);
    expect(find.text('Clear All'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('select all selects visible items', (tester) async {
    List<String> selected = [];
    await tester.pumpWidget(app(onChanged: (v) => selected = v));
    await tester.tap(find.text('Select items'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select All'));
    await tester.pump();

    expect(selected.length, 6);
  });

  testWidgets('clear all clears selected values', (tester) async {
    List<String> selected = ['Item 1', 'Item 2'];
    await tester.pumpWidget(
      app(values: selected, onChanged: (v) => selected = v),
    );
    await tester.tap(find.text('2 selected'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear All'));
    await tester.pump();

    expect(selected, isEmpty);
  });

  testWidgets('respects maxSelection', (tester) async {
    List<String> selected = [];
    await tester.pumpWidget(
      app(maxSelection: 2, onChanged: (v) => selected = v),
    );
    await tester.tap(find.text('Select items'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select All'));
    await tester.pump();

    expect(selected.length, 2);
  });
}
