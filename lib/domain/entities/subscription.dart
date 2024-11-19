import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Subscription extends Equatable {
  final String id;
  final String name;
  final double amount;
  final DateTime startDate;
  final DateTime? endDate;
  final String billingCycle; // monthly, yearly, etc.
  final int billingDay;
  final String category;
  final String userId;
  final bool isActive;

  const Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.startDate,
    required this.billingCycle,
    required this.billingDay,
    required this.category,
    required this.userId,
    this.endDate,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        startDate,
        endDate,
        billingCycle,
        billingDay,
        category,
        userId,
        isActive,
      ];

  factory Subscription.create({
    required String name,
    required double amount,
    required String billingCycle,
    required int billingDay,
    required String category,
    required String userId,
    DateTime? endDate,
  }) {
    return Subscription(
      id: const Uuid().v4(),
      name: name,
      amount: amount,
      startDate: DateTime.now(),
      billingCycle: billingCycle,
      billingDay: billingDay,
      category: category,
      userId: userId,
      endDate: endDate,
    );
  }
}
