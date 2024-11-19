// domain/usecases/subscription/get_subscriptions_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/subscription.dart';
import '../../repositories/subscription_repository.dart';

class GetSubscriptionsParams {
  final String userId;
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool includeExpired;

  GetSubscriptionsParams({
    required this.userId,
    this.category,
    this.startDate,
    this.endDate,
    this.includeExpired = true, // 기본값으로 만료된 구독도 포함
  });
}

class GetSubscriptionsUseCase
    implements UseCase<List<Subscription>, GetSubscriptionsParams> {
  final SubscriptionRepository repository;

  GetSubscriptionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Subscription>>> call(
      GetSubscriptionsParams params) async {
    try {
      // 기본 구독 목록 조회
      final result = await repository.getSubscriptions(params.userId);

      return result.fold(
        (failure) => Left(failure),
        (subscriptions) {
          var filteredSubscriptions = subscriptions;

          // 카테고리 필터링
          if (params.category != null) {
            filteredSubscriptions = filteredSubscriptions
                .where((sub) => sub.category == params.category)
                .toList();
          }

          // 날짜 범위 필터링
          if (params.startDate != null && params.endDate != null) {
            filteredSubscriptions = filteredSubscriptions.where((sub) {
              return sub.startDate.isAfter(params.startDate!) &&
                  (sub.endDate == null ||
                      sub.endDate!.isBefore(params.endDate!));
            }).toList();
          }

          // 만료된 구독 필터링
          if (!params.includeExpired) {
            final now = DateTime.now();
            filteredSubscriptions = filteredSubscriptions.where((sub) {
              return sub.endDate == null || sub.endDate!.isAfter(now);
            }).toList();
          }

          return Right(filteredSubscriptions);
        },
      );
    } catch (e) {
      return Left(
          ServerFailure('Failed to get subscriptions: ${e.toString()}'));
    }
  }
}
