// lib/presentation/pages/expense/widgets/expense_filter_chip.dart
import 'package:flutter/material.dart';

class ExpenseFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onSelected;
  final ChipThemeData? style;

  const ExpenseFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: style?.backgroundColor,
      selectedColor: style?.selectedColor,
      labelStyle: style?.labelStyle,
      padding: style?.padding,
      shape: style?.shape,
    );
  }
}
