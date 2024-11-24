import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_settings_event.dart';
import 'app_settings_state.dart';

class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  final SharedPreferences _prefs;

  AppSettingsBloc(this._prefs)
      : super(AppSettingsState(
          language: _prefs.getString('language') ?? 'korean',
          country: _prefs.getString('country') ?? 'KR',
          currency: _prefs.getString('currency') ?? 'KRW',
        )) {
    on<UpdateLanguage>(_onUpdateLanguage);
    on<UpdateCountry>(_onUpdateCountry);
    on<UpdateCurrency>(_onUpdateCurrency);
  }

  void _onUpdateLanguage(
      UpdateLanguage event, Emitter<AppSettingsState> emit) async {
    await _prefs.setString('language', event.language);
    emit(state.copyWith(language: event.language));
  }

  void _onUpdateCountry(
      UpdateCountry event, Emitter<AppSettingsState> emit) async {
    await _prefs.setString('country', event.country);
    emit(state.copyWith(country: event.country));
  }

  void _onUpdateCurrency(
      UpdateCurrency event, Emitter<AppSettingsState> emit) async {
    await _prefs.setString('currency', event.currency);
    emit(state.copyWith(currency: event.currency));
  }
}
