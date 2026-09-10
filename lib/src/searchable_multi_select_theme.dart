import 'package:flutter/material.dart';

/// Theme data for the [SearchableMultiSelect] widget.
@immutable
class SearchableMultiSelectThemeData {
  /// Creates a [SearchableMultiSelectThemeData].
  const SearchableMultiSelectThemeData({
    this.borderRadius = 14,
    this.dialogWidth = 560,
    this.maxDialogHeightFactor = .86,
    this.itemHeight = 56,
    this.searchFieldRadius = 14,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 4,
    ),
  });

  /// The border radius of the dialog.
  final double borderRadius;

  /// The width of the dialog.
  final double dialogWidth;

  /// The maximum height factor of the dialog relative to the screen height.
  final double maxDialogHeightFactor;

  /// The height of each item in the list.
  final double itemHeight;

  /// The border radius of the search field.
  final double searchFieldRadius;

  /// The padding of the content.
  final EdgeInsets contentPadding;
}
