import 'package:equatable/equatable.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/core/constants/app_locations.dart';

abstract class UserRegistrationState extends Equatable {
  const UserRegistrationState();

  @override
  List<Object?> get props => [];
}

class UserRegistrationInitial extends UserRegistrationState {}

class UserRegistrationLoading extends UserRegistrationState {}

class UserRegistrationInProgress extends UserRegistrationState {
  final AppLanguage language;
  final AppLocation? location;
  final String currency;
  final String? gender;
  final int? birthYear;

  const UserRegistrationInProgress({
    this.language = AppLanguage.korean,
    this.location,
    this.currency = 'KRW',
    this.gender,
    this.birthYear,
  });

  UserRegistrationInProgress copyWith({
    AppLanguage? language,
    AppLocation? location,
    String? currency,
    String? gender,
    int? birthYear,
  }) {
    return UserRegistrationInProgress(
      language: language ?? this.language,
      location: location ?? this.location,
      currency: currency ?? this.currency,
      gender: gender ?? this.gender,
      birthYear: birthYear ?? this.birthYear,
    );
  }

  @override
  List<Object?> get props => [language, location, currency, gender, birthYear];
}

class UserRegistrationSuccess extends UserRegistrationState {}

class UserRegistrationFailure extends UserRegistrationState {
  final String message;

  const UserRegistrationFailure(this.message);

  @override
  List<Object> get props => [message];
}
