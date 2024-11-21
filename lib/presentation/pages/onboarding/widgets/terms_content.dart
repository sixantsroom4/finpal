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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: terms.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: expandedItems.contains(index)
                  ? const Color(0xFF0C2340)
                  : const Color(0xFFE5E8EC),
              width: 1,
            ),
          ),
          child: ExpansionTile(
            title: Text(
              terms[index]['title']!,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0C2340),
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            childrenPadding: const EdgeInsets.all(20),
            expandedAlignment: Alignment.topLeft,
            onExpansionChanged: (expanded) {
              if (!readOnly) {
                onItemTap(index);
              }
            },
            initiallyExpanded: expandedItems.contains(index),
            children: [
              Text(
                terms[index]['content']!,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF4A5568),
                  height: 1.6,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
