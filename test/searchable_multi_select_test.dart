import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:searchable_spinner_multiselect/searchable_spinner_multiselect.dart';

void main() {
  final items = List.generate(6, (i) => 'Item ${i + 1}');

  Widget app({
    List<String> values = const [],
    int? maxSelection,
    ValueChanged<List<String>>? onChanged,
    SearchableMultiSelectSearch<String>? search,
    FormFieldValidator<List<String>>? validator,
    bool searchable = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          child: search == null
              ? SearchableMultiSelect<String>(
                  items: items,
                  values: values,
                  itemLabel: (e) => e,
                  maxSelection: maxSelection,
                  onChanged: onChanged ?? (_) {},
                  validator: validator,
                  searchable: searchable,
                )
              : SearchableMultiSelect<String>.async(
                  search: search,
                  values: values,
                  itemLabel: (e) => e,
                  maxSelection: maxSelection,
                  onChanged: onChanged ?? (_) {},
                  validator: validator,
                  searchable: searchable,
                ),
        ),
      ),
    );
  }

  Finder findField() => find.byType(InputDecorator);
  Finder findItem(String text) =>
      find.descendant(of: find.byType(ListView), matching: find.text(text));

  testWidgets('opens multi-select dialog', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(findField());
    await tester.pumpAndSettle();

    expect(find.text('Select All'), findsOneWidget);
    expect(find.text('Clear All'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('selects and deselects items', (tester) async {
    List<String> selected = [];
    await tester.pumpWidget(app(onChanged: (v) => selected = v));
    await tester.tap(findField());
    await tester.pumpAndSettle();

    await tester.tap(findItem('Item 1'));
    await tester.pump();
    expect(selected, contains('Item 1'));

    await tester.tap(findItem('Item 1'));
    await tester.pump();
    expect(selected, isNot(contains('Item 1')));
  });

  testWidgets('select all selects visible items', (tester) async {
    List<String> selected = [];
    await tester.pumpWidget(app(onChanged: (v) => selected = v));
    await tester.tap(findField());
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
    await tester.tap(findField());
    await tester.pumpAndSettle();

    await tester.tap(findItem('Item 1'));
    await tester.tap(findItem('Item 2'));
    await tester.tap(findItem('Item 3'));
    await tester.pump();

    expect(selected.length, 2);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('filters items via search', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(findField());
    await tester.pumpAndSettle();

    expect(findItem('Item 1'), findsOneWidget);
    expect(findItem('Item 3'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Item 1');
    await tester.pump();

    expect(findItem('Item 1'), findsOneWidget);
    expect(findItem('Item 3'), findsNothing);
  });

  testWidgets('async search works', (tester) async {
    bool searchCalled = false;
    await tester.pumpWidget(
      app(
        search: (query) async {
          searchCalled = true;
          return ['Result 1', 'Result 2'];
        },
      ),
    );

    await tester.tap(findField());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'res');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(searchCalled, isTrue);
    expect(findItem('Result 1'), findsOneWidget);
    expect(findItem('Result 2'), findsOneWidget);
  });

  testWidgets('validation works', (tester) async {
    await tester.pumpWidget(
      app(validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
    );

    expect(find.text('Required'), findsNothing);

    await tester.tap(findField());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('shows empty text when no results', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(findField());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'non-existent');
    await tester.pump();

    expect(find.text('No items found'), findsOneWidget);
  });

  testWidgets('custom items builder', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchableMultiSelect<String>(
            items: ['A'],
            values: const [],
            itemLabel: (e) => e,
            onChanged: (_) {},
            itemBuilder: (context, item, selected) => Text('Custom $item'),
          ),
        ),
      ),
    );

    await tester.tap(findField());
    await tester.pumpAndSettle();

    expect(findItem('Custom A'), findsOneWidget);
  });
}
