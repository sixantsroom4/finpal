// data/models/subscription_model.dart

import 'package:cloud_firestore/cloud_firestore.dart'; // Timestamp 처리를 위해 필요
import '../../domain/entities/subscription.dart';

class SubscriptionModel extends Subscription {
  const SubscriptionModel({
    required String id,
    required String name,
    required double amount,
    required String currency,
    required DateTime startDate,
    DateTime? endDate,
    required String billingCycle,
    required int billingDay,
    required String category,
    required String userId,
    required bool isActive,
    required bool isPaused,
  }) : super(
          id: id,
          name: name,
          amount: amount,
          currency: currency,
          startDate: startDate,
          endDate: endDate,
          billingCycle: billingCycle,
          billingDay: billingDay,
          category: category,
          userId: userId,
          isActive: isActive,
          isPaused: isPaused,
        );

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    // ─────────────────────────────────────
    // Firestore에서 startDate, endDate가 Timestamp로 들어올 수 있으므로 안전 처리
    // ─────────────────────────────────────

    // 1) startDate
    final dynamic startDateRaw = json['startDate'];
    late DateTime parsedStartDate;
    if (startDateRaw is Timestamp) {
      parsedStartDate = startDateRaw.toDate();
    } else if (startDateRaw is String) {
      parsedStartDate = DateTime.parse(startDateRaw);
    } else {
      throw FormatException("Invalid or missing 'startDate': $startDateRaw");
    }

    // 2) endDate (nullable)
    final dynamic endDateRaw = json['endDate'];
    DateTime? parsedEndDate;
    if (endDateRaw == null) {
      parsedEndDate = null;
    } else if (endDateRaw is Timestamp) {
      parsedEndDate = endDateRaw.toDate();
    } else if (endDateRaw is String) {
      parsedEndDate = DateTime.parse(endDateRaw);
    } else {
      // endDate가 이상한 타입이면 null 처리 or 예외
      parsedEndDate = null;
    }

    return SubscriptionModel(
      id: json['id'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'KRW',
      startDate: parsedStartDate,
      endDate: parsedEndDate,
      billingCycle: json['billingCycle'],
      billingDay: json['billingDay'],
      category: json['category'],
      userId: json['userId'],
      isActive: json['isActive'] ?? true,
      isPaused: json['isPaused'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'currency': currency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'billingCycle': billingCycle,
      'billingDay': billingDay,
      'category': category,
      'userId': userId,
      'isActive': isActive,
      'isPaused': isPaused,
    };
  }

  factory SubscriptionModel.fromEntity(Subscription subscription) {
    return SubscriptionModel(
      id: subscription.id,
      name: subscription.name,
      amount: subscription.amount,
      currency: subscription.currency,
      startDate: subscription.startDate,
      endDate: subscription.endDate,
      billingCycle: subscription.billingCycle,
      billingDay: subscription.billingDay,
      category: subscription.category,
      userId: subscription.userId,
      isActive: subscription.isActive,
      isPaused: subscription.isPaused,
    );
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

  /// 현재 구독이 활성 상태인지 확인
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && (endDate == null || endDate!.isAfter(now));
  }

  /// 이번 달 결제 여부 확인
  bool hasBeenBilledThisMonth() {
    final now = DateTime.now();
    final currentBillingDate = DateTime(
      now.year,
      now.month,
      billingDay,
    );
    return now.isAfter(currentBillingDate);
  }

  SubscriptionModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    String? currency,
    DateTime? startDate,
    DateTime? endDate,
    String? billingCycle,
    int? billingDay,
    String? category,
    bool? isActive,
    bool? isPaused,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      billingCycle: billingCycle ?? this.billingCycle,
      billingDay: billingDay ?? this.billingDay,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}
