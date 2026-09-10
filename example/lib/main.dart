import 'dart:async';

import 'package:flutter/material.dart';
import 'package:searchable_spinner_multiselect/searchable_spinner_multiselect.dart';

void main() => runApp(const DemoApp());

/// A simple customer model.
class Customer {
  /// Creates a [Customer].
  const Customer(this.id, this.name);

  /// The customer's unique identifier.
  final int id;

  /// The customer's name.
  final String name;

  @override
  bool operator ==(Object other) => other is Customer && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// The demo application widget.
class DemoApp extends StatefulWidget {
  /// Creates a [DemoApp].
  const DemoApp({super.key});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  final customers = List.generate(
    40,
    (index) => Customer(index + 1, 'Customer ${index + 1}'),
  );

  List<Customer> selected = [];

  Future<List<Customer>> searchCustomers(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final q = query.toLowerCase();
    return customers
        .where((e) => e.name.toLowerCase().contains(q))
        .take(15)
        .toList();
  }

  Future<List<Customer>> loadMore(String query, int page) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final q = query.toLowerCase();
    final all = customers
        .where((e) => e.name.toLowerCase().contains(q))
        .toList();
    final start = (page - 1) * 10;
    if (start >= all.length) return [];
    return all.skip(start).take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: Scaffold(
        appBar: AppBar(title: const Text('Multi Select Demo')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  SearchableMultiSelect<Customer>(
                    items: customers,
                    values: selected,
                    itemLabel: (e) => e.name,
                    label: 'Local customers',
                    maxSelection: 8,
                    onChanged: (values) => setState(() => selected = values),
                  ),
                  const SizedBox(height: 28),
                  SearchableMultiSelect<Customer>.async(
                    values: selected,
                    itemLabel: (e) => e.name,
                    label: 'Async customers',
                    search: searchCustomers,
                    loadMore: loadMore,
                    maxSelection: 8,
                    onChanged: (values) => setState(() => selected = values),
                  ),
                  const SizedBox(height: 24),
                  Text('Selected: ${selected.map((e) => e.name).join(', ')}'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
