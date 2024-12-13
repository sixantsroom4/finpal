// lib/presentation/bloc/auth/auth_event.dart
import 'package:equatable/equatable.dart';
import 'package:finpal/core/constants/app_languages.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];

  const factory AuthEvent.deleteAccount({required AppLanguage language}) =
      DeleteAccount;
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
  final String? displayName;
  final String? photoUrl;
  final String? imagePath;

  const AuthProfileUpdateRequested({
    this.displayName,
    this.photoUrl,
    this.imagePath,
  });

  @override
  List<Object?> get props => [displayName, photoUrl, imagePath];
}

class AuthEmailVerificationRequested extends AuthEvent {
  final String email;

  const AuthEmailVerificationRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class AuthAppleSignInRequested extends AuthEvent {}

class AuthAutoLoginRequested extends AuthEvent {}

class AuthTermsAcceptanceRequested extends AuthEvent {
  final bool accepted;

  AuthTermsAcceptanceRequested({required this.accepted});

  @override
  List<Object?> get props => [accepted];
}

class AuthEmailChangeRequested extends AuthEvent {
  final String newEmail;
  final String password;

  const AuthEmailChangeRequested({
    required this.newEmail,
    required this.password,
  });

  @override
  List<Object?> get props => [newEmail, password];
}

class AuthPasswordChangeRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const AuthPasswordChangeRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class AuthKakaoSignInRequested extends AuthEvent {
  @override
  List<Object?> get props => [];
}

class AuthUserRegistrationCompleted extends AuthEvent {
  const AuthUserRegistrationCompleted();

  @override
  List<Object?> get props => [];
}

class DeleteAccount extends AuthEvent {
  final AppLanguage language;

  const DeleteAccount({
    required this.language,
  });

  @override
  List<Object?> get props => [language];
}

class UpdateProfilePhoto extends AuthEvent {
  final String imagePath;

  const UpdateProfilePhoto({
    required this.imagePath,
  });

  @override
  List<Object?> get props => [imagePath];
}

class UpdateUserProfile extends AuthEvent {
  final String? displayName;
  final String? imagePath;
  final String? photoUrl;

  const UpdateUserProfile({
    this.displayName,
    this.imagePath,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [displayName, imagePath, photoUrl];
}
