import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TermsItem extends StatelessWidget {
  final String title;
  final String content;
  final bool isExpanded;
  final VoidCallback? onTap;

  const TermsItem({
    super.key,
    required this.title,
    required this.content,
    required this.isExpanded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(title),
        initiallyExpanded: isExpanded,
        onExpansionChanged: onTap != null ? (_) => onTap!() : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(content),
          ),
        ],
      ),
    );
  }
}
