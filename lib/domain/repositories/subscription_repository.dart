// domain/repositories/subscription_repository.dart
import 'package:dartz/dartz.dart';
import 'package:finpal/data/models/subscription_model.dart';
import '../entities/subscription.dart';
import '../../core/errors/failures.dart';

abstract class SubscriptionRepository {
  /// 새로운 구독 추가
  Future<Either<Failure, Subscription>> addSubscription(
      Subscription subscription);

  /// 구독 정보 업데이트
  Future<Either<Failure, Subscription>> updateSubscription(
      Subscription subscription);

  /// 구독 삭제
  Future<Either<Failure, void>> deleteSubscription(String subscriptionId);

  /// 특정 사용자의 모든 구독 목록 조회
  Future<Either<Failure, List<Subscription>>> getSubscriptions(String userId);

  /// 활성화된 구독만 조회
  Future<Either<Failure, List<Subscription>>> getActiveSubscriptions(
      String userId);

  /// 특정 구독 상세 정보 조회
  Future<Either<Failure, Subscription>> getSubscriptionById(
      String subscriptionId);

  /// 특정 날짜에 결제 예정인 구독 목록 조회
  Future<Either<Failure, List<Subscription>>> getSubscriptionsByBillingDate(
    String userId,
    int billingDay,
  );

  /// 카테고리별 구독 목록 조회
  Future<Either<Failure, List<Subscription>>> getSubscriptionsByCategory(
    String userId,
    String category,
  );

  Future<Either<Failure, void>> createExpenseFromSubscription(
      SubscriptionModel subscription);
}
