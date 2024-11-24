class AppSettingsState {
  final String language;
  final String country;
  final String currency;

  AppSettingsState({
    required this.language,
    required this.country,
    required this.currency,
  });

  AppSettingsState copyWith({
    String? language,
    String? country,
    String? currency,
  }) {
    return AppSettingsState(
      language: language ?? this.language,
      country: country ?? this.country,
      currency: currency ?? this.currency,
    );
  }
}
