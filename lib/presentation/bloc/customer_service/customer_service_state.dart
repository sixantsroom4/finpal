import 'package:equatable/equatable.dart';

abstract class CustomerServiceState extends Equatable {
  const CustomerServiceState();
}

class CustomerServiceInitial extends CustomerServiceState {
  @override
  List<Object?> get props => [];
}

class CustomerServiceLoading extends CustomerServiceState {
  @override
  List<Object?> get props => [];
}

class CustomerServiceSuccess extends CustomerServiceState {
  @override
  List<Object?> get props => [];
}

class CustomerServiceError extends CustomerServiceState {
  final String message;

  const CustomerServiceError(this.message);

  @override
  List<Object?> get props => [message];
}
