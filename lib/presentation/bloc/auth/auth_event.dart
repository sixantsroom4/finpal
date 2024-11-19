// lib/presentation/bloc/auth/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignedOut extends AuthEvent {}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthEmailSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthEmailSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthEmailSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const AuthEmailSignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object> get props => [email, password, displayName];
}

class AuthProfileUpdateRequested extends AuthEvent {
  final String displayName;
  final String? photoUrl;

  const AuthProfileUpdateRequested({
    required this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [displayName, photoUrl];
}

class AuthEmailVerificationRequested extends AuthEvent {
  final String email;

  const AuthEmailVerificationRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class AuthAppleSignInRequested extends AuthEvent {}

class AuthAutoLoginRequested extends AuthEvent {}
