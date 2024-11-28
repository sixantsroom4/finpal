import 'package:equatable/equatable.dart';
import 'package:finpal/core/constants/app_languages.dart';

class AppSettingsState extends Equatable {
  final AppLanguage language;
  final String currency;
  final String? country;
  final bool isLoading;
  final String? error;

  const AppSettingsState({
    this.language = AppLanguage.korean,
    this.currency = 'KRW',
    this.country,
    this.isLoading = false,
    this.error,
  });

  AppSettingsState copyWith({
    AppLanguage? language,
    String? currency,
    String? country,
    bool? isLoading,
    String? error,
  }) {
    return AppSettingsState(
      language: language ?? this.language,
      currency: currency ?? this.currency,
      country: country ?? this.country,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [language, currency, country, isLoading, error];
}
