// lib/presentation/bloc/auth/auth_bloc.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authStateSubscription;

  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignedOut>(_onAuthSignedOut);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthEmailSignInRequested>(_onAuthEmailSignInRequested);
    on<AuthEmailSignUpRequested>(_onAuthEmailSignUpRequested);
    on<AuthAppleSignInRequested>(_onAuthAppleSignInRequested);
    on<AuthTermsAcceptanceRequested>(_onAuthTermsAcceptanceRequested);
    on<AuthProfileUpdateRequested>((event, emit) async {
      try {
        final result = await _authRepository.updateUserProfile(
          displayName: event.displayName,
          photoUrl: event.photoUrl,
        );

        result.fold(
          (failure) => emit(AuthFailure(failure.message)),
          (user) => emit(Authenticated(user)),
        );
      } catch (e) {
        emit(AuthFailure('프로필 업데이트에 실패했습니다.'));
      }
    });

    _authStateSubscription = _authRepository.authStateChanges.listen(
      (user) {
        debugPrint('Firebase Auth 상태 변경: ${user?.email ?? "로그아웃"}');
        if (user == null) {
          emit(Unauthenticated());
        } else {
          if (state is AuthLoading) {
            debugPrint('약관 동의 처리 중 - Auth 상태 업데이트 건너뜀');
            return;
          }
          emit(Authenticated(user));
        }
      },
      onError: (error) {
        debugPrint('Firebase Auth 에러: ${error.toString()}');
        emit(AuthFailure(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('AuthCheckRequested 이벤트 처리 시작');
    emit(AuthLoading());
    try {
      final result = await _authRepository.getCurrentUser();
      debugPrint('getCurrentUser 결과: $result');
      result.fold(
        (failure) {
          debugPrint('인증 실패: ${failure.message}');
          emit(AuthFailure(failure.message));
        },
        (user) {
          debugPrint('인증 상태: ${user != null ? "인증됨" : "미인증"}');
          user != null ? emit(Authenticated(user)) : emit(Unauthenticated());
        },
      );
    } catch (e) {
      debugPrint('인증 확인 중 오류 발생: $e');
      emit(Unauthenticated());
    }
  }

  Future<void> _onAuthSignedOut(
    AuthSignedOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.signOut();
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.signInWithGoogle();
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onAuthEmailSignInRequested(
    AuthEmailSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.signInWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onAuthEmailSignUpRequested(
    AuthEmailSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.signUpWithEmailAndPassword(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onAuthAppleSignInRequested(
    AuthAppleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      print('Apple 로그인 시도 중...');

      final result = await _authRepository.signInWithApple();
      result.fold(
        (failure) {
          print('Apple 로그인 실패: ${failure.message}');
          emit(AuthFailure(failure.message));
        },
        (user) {
          print('Apple 로그인 성공: ${user.email}');
          emit(Authenticated(user));
        },
      );
    } catch (e) {
      print('예상치 못한 에러 발생: $e');
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthTermsAcceptanceRequested(
    AuthTermsAcceptanceRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugPrint('약관 동의 요청 처리 시작');
      emit(AuthLoading());
      final result =
          await _authRepository.updateTermsAcceptance(event.accepted);

      result.fold(
        (failure) {
          debugPrint('약관 동의 실패: ${failure.message}');
          emit(AuthFailure(failure.message));
        },
        (user) {
          debugPrint('약관 동의 성공: hasAcceptedTerms = ${user.hasAcceptedTerms}');
          emit(Authenticated(user.copyWith(hasAcceptedTerms: true)));
        },
      );
    } catch (e) {
      debugPrint('약관 동의 처리 중 오류: $e');
      emit(AuthFailure('약관 동의 상태 업데이트에 실패했습니다.'));
    }
  }
}
