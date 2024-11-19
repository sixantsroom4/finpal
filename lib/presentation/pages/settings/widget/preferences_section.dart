// lib/presentation/pages/settings/widgets/preferences_section.dart
import 'package:flutter/material.dart';

class PreferencesSection extends StatelessWidget {
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            '일반',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('언어'),
          subtitle: const Text('한국어'),
          onTap: () {
            // TODO: 언어 설정 구현
          },
        ),
        ListTile(
          leading: const Icon(Icons.attach_money),
          title: const Text('통화'),
          subtitle: const Text('KRW (₩)'),
          onTap: () {
            // TODO: 통화 설정 구현
          },
        ),
        ListTile(
          leading: const Icon(Icons.color_lens),
          title: const Text('테마'),
          subtitle: const Text('시스템 설정'),
          onTap: () {
            // TODO: 테마 설정 구현
          },
        ),
      ],
    );
  }
}
