import 'package:equatable/equatable.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/core/constants/app_locations.dart';

abstract class UserRegistrationEvent extends Equatable {
  const UserRegistrationEvent();

  @override
  List<Object?> get props => [];
}

class LanguageChanged extends UserRegistrationEvent {
  final AppLanguage language;
  const LanguageChanged(this.language);

  @override
  List<Object> get props => [language];
}

class LocationRequested extends UserRegistrationEvent {
  const LocationRequested();
}

class LocationChanged extends UserRegistrationEvent {
  final AppLocation location;

  const LocationChanged(this.location);

  @override
  List<Object?> get props => [location];
}

class CurrencyChanged extends UserRegistrationEvent {
  final String currency;
  const CurrencyChanged(this.currency);

  @override
  List<Object> get props => [currency];
}

class GenderChanged extends UserRegistrationEvent {
  final String gender;
  const GenderChanged(this.gender);

  @override
  List<Object> get props => [gender];
}

class BirthYearChanged extends UserRegistrationEvent {
  final int birthYear;
  const BirthYearChanged(this.birthYear);

  @override
  List<Object> get props => [birthYear];
}

class UserRegistrationCompleted extends UserRegistrationEvent {
  final String userId;
  const UserRegistrationCompleted({required this.userId});

  @override
  List<Object> get props => [userId];
}
