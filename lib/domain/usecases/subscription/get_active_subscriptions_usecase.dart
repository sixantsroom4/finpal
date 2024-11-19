import 'package:dartz/dartz.dart';
import 'package:finpal/core/errors/failures.dart';
import 'package:finpal/core/usecases/usecase.dart';
import 'package:finpal/domain/entities/subscription.dart';
import 'package:finpal/domain/repositories/subscription_repository.dart';

class GetActiveSubscriptionsUseCase
    implements UseCase<List<Subscription>, String> {
  final SubscriptionRepository repository;

  GetActiveSubscriptionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Subscription>>> call(String userId) {
    return repository.getActiveSubscriptions(userId);
  }
}
