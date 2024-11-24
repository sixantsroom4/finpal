abstract class AppSettingsEvent {}

class UpdateLanguage extends AppSettingsEvent {
  final String language;
  UpdateLanguage(this.language);
}

class UpdateCountry extends AppSettingsEvent {
  final String country;
  UpdateCountry(this.country);
}

class UpdateCurrency extends AppSettingsEvent {
  final String currency;
  UpdateCurrency(this.currency);
}
