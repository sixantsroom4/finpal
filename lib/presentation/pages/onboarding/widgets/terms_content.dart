import 'package:finpal/presentation/data/terms/kr/data_processing.dart';
import 'package:finpal/presentation/data/terms/kr/service_terms.dart';
import 'package:finpal/presentation/data/terms/kr/terms_changes.dart';
import 'package:finpal/presentation/data/terms/kr/user_responsibility.dart';
import 'package:finpal/presentation/data/terms/kr/privacy_policy.dart';
import 'package:finpal/presentation/data/terms/kr/contact_info.dart';
import 'package:flutter/material.dart';

import 'terms_item.dart';

class TermsContent extends StatelessWidget {
  final Set<int> expandedItems;
  final Function(int) onItemTap;
  final List<Map<String, String>> terms;
  final bool readOnly;

  const TermsContent({
    super.key,
    required this.expandedItems,
    required this.onItemTap,
    required this.terms,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: terms.length,
      itemBuilder: (context, index) {
        return ExpansionTile(
          title: Text(terms[index]['title']!),
          initiallyExpanded: expandedItems.contains(index),
          onExpansionChanged: readOnly ? null : (expanded) => onItemTap(index),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(terms[index]['content']!),
            ),
          ],
        );
      },
    );
  }
}
