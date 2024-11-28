import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/domain/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_settings_event.dart';
import 'app_settings_state.dart';

class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  final SharedPreferences _prefs;
  final AuthRepository _authRepository;

  AppSettingsBloc(this._prefs, this._authRepository)
      : super(AppSettingsState(
          language: _getLanguageFromString(_prefs.getString('language')),
          currency: _prefs.getString('currency') ?? 'KRW',
        )) {
    on<UpdateLanguage>(_onUpdateLanguage);
    on<UpdateCurrency>(_onUpdateCurrency);
  }

  static AppLanguage _getLanguageFromString(String? languageStr) {
    return AppLanguage.values.firstWhere(
      (e) =>
          e.toString().split('.').last.toLowerCase() ==
          (languageStr?.toLowerCase() ?? 'korean'),
      orElse: () => AppLanguage.korean,
    );
  }

  void _onUpdateLanguage(
      UpdateLanguage event, Emitter<AppSettingsState> emit) async {
    final languageString =
        event.language.toString().split('.').last.toLowerCase();
    await _prefs.setString('language', languageString);
    emit(state.copyWith(language: event.language));
  }

  void _onUpdateCurrency(
      UpdateCurrency event, Emitter<AppSettingsState> emit) async {
    await _prefs.setString('currency', event.currency);

    final currentUser = await _authRepository.getCurrentUser();
    if (currentUser.isRight()) {
      final user = currentUser.getOrElse(() => null);
      if (user != null) {
        await _authRepository.updateUserSettings(
          userId: user.id,
          settings: {
            ...user.settings ?? {},
            'currency': event.currency,
          },
        );
      }
    }

    emit(state.copyWith(currency: event.currency));
  }
}
