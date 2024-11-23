import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Subscription extends Equatable {
  final String id;
  final String name;
  final double amount;
  final String currency;
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
    required this.currency,
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
        currency,
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
      currency: 'USD',
      startDate: DateTime.now(),
      billingCycle: billingCycle,
      billingDay: billingDay,
      category: category,
      userId: userId,
      endDate: endDate,
    );
  }

  /// 현재 구독이 활성 상태인지 확인
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && (endDate == null || endDate!.isAfter(now));
  }

  /// 다음 결제일 계산
  DateTime calculateNextBillingDate() {
    final now = DateTime.now();

    // 기본 다음 결제일 계산
    DateTime nextBilling = DateTime(
      now.year,
      now.month,
      billingDay,
    );

    // 현재 날짜가 이번 달 결제일을 지났으면 다음 달로 설정
    if (nextBilling.isBefore(now)) {
      if (now.month == 12) {
        nextBilling = DateTime(now.year + 1, 1, billingDay);
      } else {
        nextBilling = DateTime(now.year, now.month + 1, billingDay);
      }
    }

    // 구독 주기에 따른 조정
    switch (billingCycle.toLowerCase()) {
      case 'monthly':
        // 이미 계산됨
        break;
      case 'yearly':
        while (nextBilling.isBefore(now)) {
          nextBilling = DateTime(
            nextBilling.year + 1,
            nextBilling.month,
            nextBilling.day,
          );
        }
        break;
      case 'weekly':
        while (nextBilling.isBefore(now)) {
          nextBilling = nextBilling.add(const Duration(days: 7));
        }
        break;
    }

    return nextBilling;
  }
}
