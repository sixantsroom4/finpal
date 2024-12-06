// lib/presentation/bloc/auth/auth_bloc.dart
import 'dart:async';

import 'package:finpal/core/constants/app_languages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authStateSubscription;
  final FirebaseFirestore _firestore;

  AuthBloc({
    required AuthRepository authRepository,
    required FirebaseFirestore firestore,
  })  : _authRepository = authRepository,
        _firestore = firestore,
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
    on<AuthEmailChangeRequested>(_onAuthEmailChangeRequested);
    on<AuthPasswordChangeRequested>(_onAuthPasswordChangeRequested);
    on<AuthKakaoSignInRequested>(_onAuthKakaoSignInRequested);
    on<AuthUserRegistrationCompleted>(_onAuthUserRegistrationCompleted);
    on<DeleteAccount>(_onDeleteAccount);

    _authStateSubscription = _authRepository.authStateChanges.listen(
      (user) {
        debugPrint('Firebase Auth 상태 변경: ${user?.email ?? "로그아웃"}');
        if (user == null) {
          emit(Unauthenticated());
        } else {
          if (state is AuthLoading ||
              state is AuthRequiresRegistration ||
              state is Authenticated) {
            // Authenticated 상태도 건너뛰도록 추가
            debugPrint('Auth 상태 업데이트 건너뜀: ${state.runtimeType}');
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

      await result.fold(
        (failure) async {
          debugPrint('인증 실패: ${failure.message}');
          emit(AuthFailure(failure.message));
        },
        (user) async {
          if (user != null) {
            // Firestore에서 최신 사용자 데이터 로드
            final userDoc =
                await _firestore.collection('users').doc(user.id).get();

            if (userDoc.exists) {
              final userData = userDoc.data()!;
              // hasAcceptedTerms 정보 포함하여 사용자 정보 업데이트
              user = user.copyWith(
                hasAcceptedTerms: userData['hasAcceptedTerms'] ?? false,
              );
            }
            if (!emit.isDone) {
              // emit이 아직 완료되지 않았는지 확인
              emit(Authenticated(user));
            }
          } else {
            if (!emit.isDone) {
              // emit이 아직 완료되지 않았는지 확인
              emit(Unauthenticated());
            }
          }
        },
      );
    } catch (e) {
      debugPrint('인증 확인 중 오류 발생: $e');
      if (!emit.isDone) {
        // emit이 아직 완료되지 않았는지 확인
        emit(Unauthenticated());
      }
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
    try {
      emit(AuthLoading());
      final result = await _authRepository.signInWithGoogle();
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) {
          if (!user.hasAcceptedTerms) {
            emit(Authenticated(user)); // 약관 동의가 필요한 상태
          } else {
            emit(Authenticated(user)); // 이미 약관에 동의한 상태
          }
        },
      );
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
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
          emit(AuthRequiresRegistration(user));
        },
      );
    } catch (e) {
      debugPrint('약관 동의 처리 중 오류: $e');
      emit(AuthFailure('약관 동의 상태 업데이트에 실패했습니다.'));
    }
  }

  Future<void> _onAuthEmailChangeRequested(
    AuthEmailChangeRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final result = await _authRepository.updateEmail(
        newEmail: event.newEmail,
        password: event.password,
      );

      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(Authenticated(user)),
      );
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthPasswordChangeRequested(
    AuthPasswordChangeRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final result = await _authRepository.updatePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );

      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(state), // 비밀번호 변경은 인증 상태를 변경하지 않습니다
      );
    } catch (e) {
      emit(AuthFailure('비밀번호  습니다: ${e.toString()}'));
    }
  }

  Future<void> _onAuthKakaoSignInRequested(
    AuthKakaoSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      print('카카오 로그인 시도 중...');

      final result = await _authRepository.signInWithKakao();
      result.fold(
        (failure) {
          print('카카오 로그인 실패: ${failure.message}');
          emit(AuthFailure(failure.message));
        },
        (user) {
          print('카카오 로그인 성공: ${user.email}');
          emit(Authenticated(user));
        },
      );
    } catch (e) {
      print('예상치 못한 에러 발생: $e');
      emit(AuthFailure('카카오 로그인 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }

  Future<void> _onAuthUserRegistrationCompleted(
    AuthUserRegistrationCompleted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      // 약관 동의 상태 업데이트
      final termsResult = await _authRepository.updateTermsAcceptance(true);

      if (termsResult.isLeft()) {
        emit(AuthFailure(termsResult.fold(
          (failure) => failure.message,
          (_) => '',
        )));
        return;
      }

      // 새로운 사용자 정보를 가져오기 전에 잠시 대기
      await Future.delayed(const Duration(milliseconds: 500));

      final userResult = await _authRepository.getCurrentUser();
      userResult.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) {
          if (user != null) {
            // hasAcceptedTerms가 true인 상태로 Authenticated 상태로 변경
            emit(Authenticated(user.copyWith(hasAcceptedTerms: true)));
          } else {
            emit(const AuthFailure('사용자 정보를 찾을 수 없습니다.'));
          }
        },
      );
    } catch (e) {
      emit(const AuthFailure('사용자 등록 상태 업데이트에 실패했습니다.'));
    }
  }

  void _onDeleteAccount(DeleteAccount event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      await _authRepository.deleteAccount();
      emit(Unauthenticated());
    } catch (e) {
      final language = event.language; // 언어 설정 가져오기
      String errorMessage;

      switch (language) {
        case AppLanguage.english:
          errorMessage = 'Failed to delete account';
        case AppLanguage.japanese:
          errorMessage = 'アカウントの削除に失敗しました';
        case AppLanguage.korean:
        default:
          errorMessage = '계정 삭제에 실패했습니다';
      }

      emit(AuthFailure('$errorMessage: ${e.toString()}'));
      emit(state);
    }
  }
}
