import 'package:dartz/dartz.dart';
import 'package:finpal/core/errors/failures.dart';
import 'package:finpal/core/usecases/usecase.dart';
import 'package:finpal/domain/entities/subscription.dart';
import 'package:finpal/domain/repositories/subscription_repository.dart';

class AddSubscriptionUseCase implements UseCase<Subscription, Subscription> {
  final SubscriptionRepository repository;

  AddSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, Subscription>> call(Subscription params) {
    return repository.addSubscription(params);
  }
}
