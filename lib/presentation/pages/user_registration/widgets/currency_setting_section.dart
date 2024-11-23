import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_state.dart';

class CurrencySettingSection extends StatelessWidget {
  const CurrencySettingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserRegistrationBloc, UserRegistrationState>(
      builder: (context, registrationState) {
        return BlocBuilder<AppLanguageBloc, AppLanguageState>(
          builder: (context, languageState) {
            // 현재 선택된 통화 (거주국 기반 또는 이전 선택값)
            final String currentCurrency =
                registrationState is UserRegistrationInProgress
                    ? registrationState.currency
                    : 'KRW'; // 기본값

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLocalizedTitle(context),
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
                    value: currentCurrency,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    items: [
                      _buildDropdownMenuItem('KRW',
                          '🇰🇷 ${_getLocalizedCurrency(context, "KRW")}'),
                      _buildDropdownMenuItem('JPY',
                          '🇯🇵 ${_getLocalizedCurrency(context, "JPY")}'),
                      _buildDropdownMenuItem('USD',
                          '🇺🇸 ${_getLocalizedCurrency(context, "USD")}'),
                      _buildDropdownMenuItem('EUR',
                          '🇪🇺 ${_getLocalizedCurrency(context, "EUR")}'),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<UserRegistrationBloc>().add(
                              CurrencyChanged(newValue),
                            );
                      }
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Default Currency',
      AppLanguage.korean: '기본 통화',
      AppLanguage.japanese: '基本通貨',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedCurrency(BuildContext context, String currency) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> currencies = {
      'KRW': {
        AppLanguage.english: 'Korean Won (KRW)',
        AppLanguage.korean: '원화 (KRW)',
        AppLanguage.japanese: 'ウォン (KRW)',
      },
      'JPY': {
        AppLanguage.english: 'Japanese Yen (JPY)',
        AppLanguage.korean: '엔화 (JPY)',
        AppLanguage.japanese: '円 (JPY)',
      },
      'USD': {
        AppLanguage.english: 'US Dollar (USD)',
        AppLanguage.korean: '달러 (USD)',
        AppLanguage.japanese: 'ドル (USD)',
      },
      'EUR': {
        AppLanguage.english: 'Euro (EUR)',
        AppLanguage.korean: '유로 (EUR)',
        AppLanguage.japanese: 'ユーロ (EUR)',
      },
    };
    return currencies[currency]?[language] ??
        currencies[currency]![AppLanguage.korean]!;
  }

  DropdownMenuItem<String> _buildDropdownMenuItem(String value, String label) {
    return DropdownMenuItem(
      value: value,
      child: Text(label),
    );
  }
}
