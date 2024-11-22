import 'package:finpal/core/constants/app_languages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_event.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_state.dart';
import 'package:finpal/core/constants/app_locations.dart';

class LocationSection extends StatelessWidget {
  const LocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserRegistrationBloc, UserRegistrationState>(
      builder: (context, state) {
        return BlocBuilder<AppLanguageBloc, AppLanguageState>(
          builder: (context, languageState) {
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
                  child: Column(
                    children: AppLocation.values.map((location) {
                      return RadioListTile<AppLocation>(
                        title: Text(_getLocalizedLocation(context, location)),
                        subtitle: Text(
                            _getLocalizedCurrency(context, location.currency)),
                        value: location,
                        groupValue: state is UserRegistrationInProgress
                            ? state.location
                            : null,
                        onChanged: (AppLocation? value) {
                          if (value != null) {
                            context.read<UserRegistrationBloc>()
                              ..add(LocationChanged(value))
                              ..add(CurrencyChanged(value.currency));
                          }
                        },
                      );
                    }).toList(),
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
      AppLanguage.english: 'Location',
      AppLanguage.korean: '거주 국가',
      AppLanguage.japanese: '居住国',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedLocation(BuildContext context, AppLocation location) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<AppLocation, Map<AppLanguage, String>> locations = {
      AppLocation.korea: {
        AppLanguage.english: 'South Korea',
        AppLanguage.korean: '대한민국',
        AppLanguage.japanese: '韓国',
      },
      AppLocation.japan: {
        AppLanguage.english: 'Japan',
        AppLanguage.korean: '일본',
        AppLanguage.japanese: '日本',
      },
      AppLocation.usa: {
        AppLanguage.english: 'United States',
        AppLanguage.korean: '미국',
        AppLanguage.japanese: 'アメリカ',
      },
      AppLocation.europe: {
        AppLanguage.english: 'Europe',
        AppLanguage.korean: '유럽',
        AppLanguage.japanese: 'ヨーロッパ',
      },
    };
    return locations[location]?[language] ??
        locations[location]![AppLanguage.korean]!;
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
}
