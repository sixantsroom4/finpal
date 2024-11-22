import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class AppLanguageEvent {}

class AppLanguageChanged extends AppLanguageEvent {
  final AppLanguage language;
  AppLanguageChanged(this.language);
}

// State
class AppLanguageState {
  final AppLanguage language;
  AppLanguageState(this.language);
}

// Bloc
class AppLanguageBloc extends Bloc<AppLanguageEvent, AppLanguageState> {
  final SharedPreferences _prefs;

  AppLanguageBloc(this._prefs)
      : super(AppLanguageState(_loadInitialLanguage(_prefs))) {
    on<AppLanguageChanged>((event, emit) async {
      emit(AppLanguageState(event.language));
      await _prefs.setString('app_language', event.language.code);
    });
  }

  static AppLanguage _loadInitialLanguage(SharedPreferences prefs) {
    final savedLanguage = prefs.getString('app_language');
    if (savedLanguage != null) {
      return AppLanguage.values.firstWhere(
        (lang) => lang.code == savedLanguage,
        orElse: () => AppLanguage.korean,
      );
    }
    return AppLanguage.korean;
  }
}
