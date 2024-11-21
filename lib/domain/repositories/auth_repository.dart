// domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  /// 현재 로그인된 사용자 정보 스트림
  Stream<User?> get authStateChanges;

  /// 현재 로그인된 사용자 조회
  Future<Either<Failure, User?>> getCurrentUser();

  /// 이메일/비밀번호로 회원가입
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// 이메일/비밀번호로 로그인
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// 구글 계정으로 로그인
  Future<Either<Failure, User>> signInWithGoogle();

  /// 로그아웃
  Future<Either<Failure, void>> signOut();

  /// 비밀번호 재설정 이메일 발송
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// 사용자 프로필 업데이트
  Future<Either<Failure, User>> updateUserProfile({
    String? displayName,
    String? photoUrl,
  });

  /// 사용자 설정 업데이트
  Future<Either<Failure, User>> updateUserSettings({
    required String userId,
    required Map<String, dynamic> settings,
  });

  /// 계정 삭제
  Future<Either<Failure, void>> deleteAccount();

  /// 이메일 인증 코드 발송
  Future<Either<Failure, void>> sendVerificationEmail(String email);

  /// 이메일 인증 코드 확인
  Future<Either<Failure, void>> verifyEmailCode(String email, String code);

  Future<Either<Failure, User>> signInWithApple();

  Future<Either<Failure, User>> updateTermsAcceptance(bool accepted);

  /// 이메일 주소 변경
  Future<Either<Failure, User>> updateEmail({
    required String newEmail,
    required String password,
  });

  /// 비밀번호 변경
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// 카카오 계정으로 로그인
  Future<Either<Failure, User>> signInWithKakao();
}
