// lib/presentation/bloc/auth/auth_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  final String? error;

  const Authenticated(this.user, {this.error});

  @override
  List<Object?> get props => [user, error];
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

class AuthRequiresRegistration extends AuthState {
  final User user;

  const AuthRequiresRegistration(this.user);

  @override
  List<Object?> get props => [user];
}
