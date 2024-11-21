import 'package:finpal/core/constants/app_languages.dart';
import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final AppLanguage selectedLanguage;
  final Function(AppLanguage) onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton<AppLanguage>(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        offset: const Offset(0, 40),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language, size: 20),
              const SizedBox(width: 8),
              Text(
                selectedLanguage.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
        itemBuilder: (context) => AppLanguage.values.map((language) {
          return PopupMenuItem<AppLanguage>(
            value: language,
            child: Row(
              children: [
                Text(
                  language.label,
                  style: TextStyle(
                    fontWeight: language == selectedLanguage
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: language == selectedLanguage
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                if (language == selectedLanguage) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ],
            ),
          );
        }).toList(),
        onSelected: onLanguageChanged,
      ),
    );
  }
}
