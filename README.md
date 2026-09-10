# searchable_spinner_multiselect

A modern Flutter searchable multi-select widget with:

- Multi-selection
- Search/filter
- Select All
- Clear All
- Selected count
- Maximum selection
- Async/API search
- Debounced search
- Pagination / load-more
- Custom item builder
- Custom selected text
- Form validation
- Material 3 responsive UI
- No runtime third-party dependencies

## Install

```yaml
dependencies:
  searchable_spinner_multiselect: ^1.0.0
```

Then:

```bash
flutter pub get
```

## Basic usage

```dart
import 'package:searchable_spinner_multiselect/searchable_spinner_multiselect.dart';

SearchableMultiSelect<Customer>(
  items: customers,
  values: selectedCustomers,
  itemLabel: (customer) => customer.name,
  label: 'Customers',
  maxSelection: 10,
  onChanged: (values) {
    setState(() => selectedCustomers = values);
  },
);
```

## Async search

```dart
SearchableMultiSelect<Product>.async(
  values: selectedProducts,
  itemLabel: (product) => product.name,
  search: (query) => repository.searchProducts(query),
  loadMore: (query, page) {
    return repository.searchProducts(query, page: page);
  },
  onChanged: (values) {
    setState(() => selectedProducts = values);
  },
);
```

## Important Select All behavior

For local data, Select All selects all currently visible filtered items.

For async/paginated data, Select All applies to the currently loaded/visible results. It does not claim to select records that have not been loaded from the server.

## Validation

```dart
Form(
  child: SearchableMultiSelect<Customer>(
    items: customers,
    values: selectedCustomers,
    itemLabel: (customer) => customer.name,
    validator: (values) {
      if (values == null || values.isEmpty) {
        return 'Please select at least one customer';
      }
      return null;
    },
    onChanged: (values) {
      setState(() => selectedCustomers = values);
    },
  ),
)
```

## Development

```bash
flutter pub get
dart format .
flutter analyze
flutter test
dart doc
dart pub publish --dry-run
```

The package follows the standard Dart package structure with public APIs in `lib/`, implementation under `lib/src/`, tests in `test/`, and an example under `example/`.
