// data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/firebase_auth_remote_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthRemoteDataSource remoteDataSource;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
  Stream<User?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final user = await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      return Right(user);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = await remoteDataSource.updateUserProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserSettings({
    required String userId,
    required Map<String, dynamic> settings,
  }) async {
    try {
      final user = await remoteDataSource.updateUserSettings(
        userId: userId,
        settings: settings,
      );
      return Right(user);
    } on DatabaseException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendVerificationEmail(String email) async {
    try {
      await remoteDataSource.sendVerificationEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmailCode(
      String email, String code) async {
    try {
      await remoteDataSource.verifyEmailCode(email, code);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    try {
      final user = await remoteDataSource.signInWithApple();
      return Right(user);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateTermsAcceptance(bool accepted) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser.isLeft()) {
        return Left(ServerFailure('사용자를 찾을 수 없습니다'));
      }

      final user = currentUser.getOrElse(() => throw Exception());
      if (user == null) {
        return Left(ServerFailure('사용자를 찾을 수 없습니다'));
      }

      await _firestore.collection('users').doc(user.id).update({
        'hasAcceptedTerms': accepted,
      });

      return Right(user.copyWith(hasAcceptedTerms: accepted));
    } catch (e) {
      return Left(ServerFailure('약관 동의 상태 업데이트 실패: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.updateEmail(
        newEmail: newEmail,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithKakao() async {
    try {
      final user = await remoteDataSource.signInWithKakao();
      return Right(user);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
