import 'package:equatable/equatable.dart';
import '../../../domain/entities/subscription.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubscriptions extends SubscriptionEvent {
  final String userId;

  const LoadSubscriptions(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadActiveSubscriptions extends SubscriptionEvent {
  final String userId;

  const LoadActiveSubscriptions(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddSubscription extends SubscriptionEvent {
  final Subscription subscription;

  const AddSubscription(this.subscription);

  @override
  List<Object> get props => [subscription];
}

class UpdateSubscription extends SubscriptionEvent {
  final Subscription subscription;

  const UpdateSubscription(this.subscription);

  @override
  List<Object> get props => [subscription];
}

class DeleteSubscription extends SubscriptionEvent {
  final String subscriptionId;

  const DeleteSubscription({required this.subscriptionId});

  @override
  List<Object> get props => [subscriptionId];
}

class CancelSubscription extends SubscriptionEvent {
  final String subscriptionId;
  final String userId;

  const CancelSubscription(this.subscriptionId, this.userId);

  @override
  List<Object> get props => [subscriptionId, userId];
}

class LoadSubscriptionsByCategory extends SubscriptionEvent {
  final String userId;
  final String category;

  const LoadSubscriptionsByCategory({
    required this.userId,
    required this.category,
  });

  @override
  List<Object> get props => [userId, category];
}

class LoadSubscriptionsByBillingDate extends SubscriptionEvent {
  final String userId;
  final int billingDay;

  const LoadSubscriptionsByBillingDate({
    required this.userId,
    required this.billingDay,
  });

  @override
  List<Object> get props => [userId, billingDay];
}

class LoadSubscriptionById extends SubscriptionEvent {
  final String subscriptionId;

  const LoadSubscriptionById(this.subscriptionId);

  @override
  List<Object> get props => [subscriptionId];
}
