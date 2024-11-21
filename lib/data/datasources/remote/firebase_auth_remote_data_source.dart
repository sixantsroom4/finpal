// data/datasources/remote/firebase_auth_remote_data_source.dart
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';

abstract class FirebaseAuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel> updateUserProfile({
    String? displayName,
    String? photoUrl,
  });
  Future<UserModel> updateUserSettings({
    required String userId,
    required Map<String, dynamic> settings,
  });
  Future<void> deleteAccount();
  Future<UserModel> signInWithApple();
  Future<void> sendVerificationEmail(String email);
  Future<void> verifyEmailCode(String email, String code);
  Future<UserModel> updateTermsAcceptance(bool accepted);
  Future<UserModel> updateEmail({
    required String newEmail,
    required String password,
  });
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class FirebaseAuthRemoteDataSourceImpl implements FirebaseAuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  FirebaseAuthRemoteDataSourceImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _firestore = firestore;

  @override
  Stream<UserModel?> get authStateChanges =>
      _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
        if (firebaseUser == null) return null;

        try {
          final userDoc =
              await _firestore.collection('users').doc(firebaseUser.uid).get();
          if (!userDoc.exists) {
            return UserModel.fromFirebaseUser(firebaseUser);
          }
          return UserModel.fromJson({
            ...userDoc.data()!,
            'id': firebaseUser.uid,
            'email': firebaseUser.email ?? '',
            'displayName': firebaseUser.displayName ??
                'User${firebaseUser.uid.substring(0, 6)}',
            'photoUrl': firebaseUser.photoURL,
          });
        } catch (e) {
          debugPrint('사용자 데이터 조회 실패: $e');
          return UserModel.fromFirebaseUser(firebaseUser);
        }
      });

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      // Firestore에서 추가 사용자 데이터 가져오기
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        return UserModel.fromJson({
          'id': firebaseUser.uid,
          'email': firebaseUser.email ?? '',
          'displayName': firebaseUser.displayName ??
              'User${firebaseUser.uid.substring(0, 6)}',
          'photoUrl': firebaseUser.photoURL ?? '',
          'createdAt': DateTime.now().toIso8601String(),
          'settings': {
            'theme': 'system',
            'notifications': {
              'expenses': true,
              'subscriptions': true,
              'shared': true,
            },
            'currency': 'KRW',
            'language': 'ko',
          },
        });
      }

      return UserModel.fromJson({
        ...userDoc.data()!,
        'id': firebaseUser.uid,
        'email': firebaseUser.email ?? '',
        'displayName': firebaseUser.displayName ??
            'User${firebaseUser.uid.substring(0, 6)}',
        'photoUrl': firebaseUser.photoURL ?? '',
      });
    } catch (e) {
      debugPrint('getCurrentUser 에러: $e');
      throw AuthException('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw AuthException('Failed to create user');
      }

      // 사용자 프로필 업데이트
      await firebaseUser.updateDisplayName(displayName);

      // Firestore에 추가 사용자 데이터 저장
      final userModel = UserModel.fromFirebaseUser(firebaseUser);
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userModel.toJson());

      return userModel;
    } catch (e) {
      throw AuthException(_getFirebaseAuthErrorMessage(e));
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw AuthException('Failed to sign in');
      }

      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        return UserModel.fromFirebaseUser(firebaseUser);
      }

      return UserModel.fromJson({
        ...userDoc.data()!,
        'id': firebaseUser.uid,
        'email': firebaseUser.email,
        'displayName': firebaseUser.displayName,
        'photoUrl': firebaseUser.photoURL,
      });
    } catch (e) {
      throw AuthException(_getFirebaseAuthErrorMessage(e));
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Google sign in aborted');
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw AuthException('Failed to sign in with Google');
      }

      // Firestore에 사용자 데이터 저장 또는 업데이트
      final userModel = UserModel.fromFirebaseUser(firebaseUser);
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userModel.toJson(), SetOptions(merge: true));

      return userModel;
    } catch (e) {
      throw AuthException('Failed to sign in with Google: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw AuthException(_getFirebaseAuthErrorMessage(e));
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw AuthException('No user signed in');
      }

      if (displayName != null) {
        await firebaseUser.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await firebaseUser.updatePhotoURL(photoUrl);
      }

      // Firestore 데이터 업데이트
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });

      final user = await getCurrentUser();
      if (user == null) {
        throw AuthException('Failed to get updated user');
      }
      return user;
    } catch (e) {
      throw AuthException('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateUserSettings({
    required String userId,
    required Map<String, dynamic> settings,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'settings': settings,
      });

      final user = await getCurrentUser();
      if (user == null) {
        throw AuthException('Failed to get updated user');
      }
      return user;
    } catch (e) {
      throw AuthException('Failed to update settings: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw AuthException('No user signed in');
      }

      // Firestore 데이터 삭제
      await _firestore.collection('users').doc(firebaseUser.uid).delete();

      // Firebase Auth 계정 삭제
      await firebaseUser.delete();
    } catch (e) {
      throw AuthException('Failed to delete account: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      print('Apple 로그인 시도...');

      // nonce 보안 추가
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      if (appleCredential.identityToken == null) {
        throw AuthException('Apple 인증 토큰을 받지 못했습니다.');
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken!,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      print('Firebase 인증 시도...');
      final userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw AuthException('Firebase 사용자 정보를 받지 못했습니다.');
      }
      print('Firebase 인증 성공');

      // 사용자 정보 구성 - 더 안전한 null 처리
      String email = firebaseUser.email ??
          appleCredential.email ??
          '${firebaseUser.uid}_${DateTime.now().millisecondsSinceEpoch}@tempmail.finpal.com';

      String displayName = firebaseUser.displayName ??
          [appleCredential.givenName, appleCredential.familyName]
              .where((name) => name != null && name.isNotEmpty)
              .join(' ')
              .trim();

      if (displayName.isEmpty) {
        displayName = 'User${firebaseUser.uid.substring(0, 6)}';
      }

      // Firestore 데이터 처리 - 기존 사용자 확인
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      final UserModel userModel;

      if (!userDoc.exists ||
          userCredential.additionalUserInfo?.isNewUser == true) {
        userModel = UserModel(
          id: firebaseUser.uid,
          email: email,
          displayName: displayName,
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          settings: const {
            'theme': 'system',
            'notifications': {
              'expenses': true,
              'subscriptions': true,
              'shared': true,
            },
            'currency': 'KRW',
            'language': 'ko',
          },
        );

        // 새 사용자의 경우 Firestore에 데이터 저장
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(userModel.toJson(), SetOptions(merge: true));
      } else {
        // 기존 사용자의 경우 현재 데이터 유지
        userModel = UserModel.fromJson({
          ...userDoc.data()!,
          'id': firebaseUser.uid,
          'email': email,
          'displayName': displayName,
          'photoUrl': firebaseUser.photoURL,
        });
      }

      print('Apple 로그인 완료: ${userModel.email}');
      return userModel;
    } on SignInWithAppleAuthorizationException catch (e) {
      print('Apple 인증 에러: ${e.code} - ${e.message}');
      throw AuthException('Apple 로그인이 취소되었습니다.');
    } on FirebaseAuthException catch (e) {
      print('Firebase 인증 에러: ${e.code} - ${e.message}');
      throw AuthException(e.message ?? 'Firebase 인증 중 오류가 발생했습니다.');
    } catch (e) {
      print('예상치 못한 에러: $e');
      throw AuthException('로그인 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> sendVerificationEmail(String email) async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> verifyEmailCode(String email, String code) async {
    try {
      // Firebase 이메일 인증 코드 확인 로직 구현
      await _firebaseAuth.checkActionCode(code);
      await _firebaseAuth.applyActionCode(code);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> updateTermsAcceptance(bool accepted) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw AuthException('사용자를 찾을 수 없습니다.');
      }

      // Firestore에 약관 동의 상태 저장
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'hasAcceptedTerms': accepted,
        'termsAcceptedAt': DateTime.now().toIso8601String(),
      });

      // 업데이트된 사용자 정보 반환
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      return UserModel.fromJson({
        ...userDoc.data()!,
        'id': firebaseUser.uid,
        'email': firebaseUser.email ?? '',
        'displayName': firebaseUser.displayName,
        'hasAcceptedTerms': accepted,
      });
    } catch (e) {
      throw AuthException('약관 동의 상태 업데이트에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw AuthException('사용자를 찾을 수 없습니다.');
      }

      // 재인증
      final credential = EmailAuthProvider.credential(
        email: firebaseUser.email!,
        password: password,
      );
      await firebaseUser.reauthenticateWithCredential(credential);

      // 이메일 변경
      await firebaseUser.verifyBeforeUpdateEmail(newEmail);

      // Firestore 데이터 업데이트
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'email': newEmail,
      });

      final user = await getCurrentUser();
      if (user == null) {
        throw AuthException('사용자 정보를 가져오는데 실패했습니다.');
      }
      return user;
    } catch (e) {
      throw AuthException('이메일 변경에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw AuthException('사용자를 찾을 수 없습니다.');
      }

      // 현재 비밀번호로 재인증
      final credential = EmailAuthProvider.credential(
        email: firebaseUser.email!,
        password: currentPassword,
      );
      await firebaseUser.reauthenticateWithCredential(credential);

      // 새 비밀번호로 변경
      await firebaseUser.updatePassword(newPassword);
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            throw AuthException('현재 비밀번호가 올바르지 않습니다.');
          case 'weak-password':
            throw AuthException('새 비밀번호가 너무 약합니다.');
          default:
            throw AuthException('비밀번호 변경에 실패했습니다: ${e.message}');
        }
      }
      throw AuthException('비밀번호 변경에 실패했습니다: ${e.toString()}');
    }
  }

  String _getFirebaseAuthErrorMessage(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'The email address is already registered.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled.';
        default:
          return error.message ?? 'An unknown error occurred.';
      }
    }
    return error.toString();
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
