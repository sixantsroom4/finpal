import 'package:equatable/equatable.dart';
import '../../../domain/entities/subscription.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final List<Subscription> subscriptions;
  final double monthlyTotal;
  final double yearlyTotal;
  final Map<String, double> categoryTotals;
  final Map<int, List<Subscription>> billingDaySubscriptions;

  const SubscriptionLoaded({
    required this.subscriptions,
    required this.monthlyTotal,
    required this.yearlyTotal,
    required this.categoryTotals,
    required this.billingDaySubscriptions,
  });

  @override
  List<Object> get props => [
        subscriptions,
        monthlyTotal,
        yearlyTotal,
        categoryTotals,
        billingDaySubscriptions,
      ];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object> get props => [message];
}

class SubscriptionOperationSuccess extends SubscriptionState {
  final String message;

  const SubscriptionOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
