import 'package:finpal/presentation/data/terms/data_processing.dart';
import 'package:finpal/presentation/data/terms/service_terms.dart';
import 'package:finpal/presentation/data/terms/terms_changes.dart';
import 'package:finpal/presentation/data/terms/user_responsibility.dart';
import 'package:finpal/presentation/data/terms/privacy_policy.dart';
import 'package:finpal/presentation/data/terms/contact_info.dart';
import 'package:flutter/material.dart';

import 'terms_item.dart';

class TermsContent extends StatelessWidget {
  final Set<int> expandedItems;
  final Function(int) onItemTap;

  const TermsContent({
    super.key,
    required this.expandedItems,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final terms = [
      (ServiceTerms.title, ServiceTerms.content),
      (DataProcessing.title, DataProcessing.content),
      (UserResponsibility.title, UserResponsibility.content),
      (TermsChanges.title, TermsChanges.content),
      (PrivacyPolicy.title, PrivacyPolicy.content),
      (ContactInfo.title, ContactInfo.content),
    ];

    return Column(
      children: [
        for (int i = 0; i < terms.length; i++) ...[
          TermsItem(
            title: terms[i].$1,
            content: terms[i].$2,
            isExpanded: expandedItems.contains(i),
            onTap: () => onItemTap(i),
          ),
          if (i < terms.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}
