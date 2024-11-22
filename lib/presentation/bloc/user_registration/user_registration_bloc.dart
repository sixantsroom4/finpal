import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finpal/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'user_registration_event.dart';
import 'user_registration_state.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';

class UserRegistrationBloc
    extends Bloc<UserRegistrationEvent, UserRegistrationState> {
  final AuthRepository _authRepository;

  UserRegistrationBloc({
    required AuthRepository authRepository,
    required AppLanguageBloc appLanguageBloc,
  })  : _authRepository = authRepository,
        super(UserRegistrationInProgress(
            language: appLanguageBloc.state.language)) {
    on<LanguageChanged>(_onLanguageChanged);
    on<LocationChanged>(_onLocationChanged);
    on<CurrencyChanged>(_onCurrencyChanged);
    on<GenderChanged>(_onGenderChanged);
    on<BirthYearChanged>(_onBirthYearChanged);
    on<UserRegistrationCompleted>(_onUserRegistrationCompleted);
  }

  void _onLanguageChanged(
      LanguageChanged event, Emitter<UserRegistrationState> emit) {
    if (state is UserRegistrationInProgress) {
      emit((state as UserRegistrationInProgress)
          .copyWith(language: event.language));
    } else {
      emit(UserRegistrationInProgress(language: event.language));
    }
  }

  void _onLocationChanged(
      LocationChanged event, Emitter<UserRegistrationState> emit) {
    if (state is UserRegistrationInProgress) {
      emit((state as UserRegistrationInProgress)
          .copyWith(location: event.location));
    } else {
      emit(UserRegistrationInProgress(location: event.location));
    }
  }

  void _onCurrencyChanged(
      CurrencyChanged event, Emitter<UserRegistrationState> emit) {
    if (state is UserRegistrationInProgress) {
      emit((state as UserRegistrationInProgress)
          .copyWith(currency: event.currency));
    } else {
      emit(UserRegistrationInProgress(currency: event.currency));
    }
  }

  void _onGenderChanged(
      GenderChanged event, Emitter<UserRegistrationState> emit) {
    if (state is UserRegistrationInProgress) {
      emit(
          (state as UserRegistrationInProgress).copyWith(gender: event.gender));
    } else {
      emit(UserRegistrationInProgress(gender: event.gender));
    }
  }

  void _onBirthYearChanged(
      BirthYearChanged event, Emitter<UserRegistrationState> emit) {
    if (state is UserRegistrationInProgress) {
      emit((state as UserRegistrationInProgress)
          .copyWith(birthYear: event.birthYear));
    } else {
      emit(UserRegistrationInProgress(birthYear: event.birthYear));
    }
  }

  Future<void> _onUserRegistrationCompleted(
    UserRegistrationCompleted event,
    Emitter<UserRegistrationState> emit,
  ) async {
    try {
      emit(UserRegistrationLoading());

      if (state is! UserRegistrationInProgress) {
        emit(const UserRegistrationFailure('잘못된 상태입니다.'));
        return;
      }

      final currentState = state as UserRegistrationInProgress;

      if (currentState.location == null ||
          currentState.gender == null ||
          currentState.birthYear == null) {
        emit(const UserRegistrationFailure('모든 정보를 입력해주세요.'));
        return;
      }

      final result = await _authRepository.updateUserSettings(
        userId: event.userId,
        settings: {
          'language': currentState.language.name,
          'location': currentState.location!.name,
          'currency': currentState.currency,
          'gender': currentState.gender,
          'birthYear': currentState.birthYear,
        },
      );

      result.fold(
        (failure) => emit(UserRegistrationFailure(failure.message)),
        (_) => emit(UserRegistrationSuccess()),
      );
    } catch (e) {
      emit(const UserRegistrationFailure('사용자 설정 업데이트에 실패했습니다.'));
    }
  }
}
