import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class CurrencyEvent {}

class CurrencyChanged extends CurrencyEvent {
  final String currency;
  CurrencyChanged(this.currency);
}

// State
class CurrencyState {
  final String currency;
  const CurrencyState({this.currency = 'KRW'});
}

// Bloc
class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final SharedPreferences _prefs;

  CurrencyBloc(this._prefs)
      : super(CurrencyState(currency: _prefs.getString('currency') ?? 'KRW')) {
    on<CurrencyChanged>((event, emit) async {
      await _prefs.setString('currency', event.currency);
      emit(CurrencyState(currency: event.currency));
    });
  }
}
