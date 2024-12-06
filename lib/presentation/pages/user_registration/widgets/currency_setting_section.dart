import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_event.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_state.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_state.dart';
import 'package:finpal/presentation/bloc/currency/currency_bloc.dart';
import 'package:finpal/core/constants/app_currencies.dart';

class CurrencySettingSection extends StatelessWidget {
  const CurrencySettingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsBloc, AppSettingsState>(
      builder: (context, settingsState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getLocalizedLabel(context, 'currency_setting'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0C2340),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E8EC)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                value: settingsState.currency,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                items: AppCurrencies.currencies.keys.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(AppCurrencies.getLocalizedCurrency(
                      context.read<AppLanguageBloc>().state.language,
                      currency,
                    )),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    context
                        .read<AppSettingsBloc>()
                        .add(UpdateCurrency(newValue));
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'currency_setting': {
        AppLanguage.english: 'Default Currency',
        AppLanguage.korean: '기본 통화 설정',
        AppLanguage.japanese: '基本通貨設定',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }
}
