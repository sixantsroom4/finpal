// data/repositories/subscription_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/remote/firebase_storage_remote_data_source.dart';
import '../models/subscription_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final FirebaseStorageRemoteDataSource remoteDataSource;

  SubscriptionRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, Subscription>> addSubscription(
    Subscription subscription,
  ) async {
    try {
      final subscriptionModel = SubscriptionModel.fromEntity(subscription);

      // 기존 구독과의 중복 검사
      final existingSubscriptions = await remoteDataSource.getSubscriptions(
        subscription.userId,
      );

      final isDuplicate = existingSubscriptions.any((sub) =>
          sub.name.toLowerCase() == subscription.name.toLowerCase() &&
          sub.isActive);

      if (isDuplicate) {
        return Left(ValidationFailure(
          'An active subscription with this name already exists',
        ));
      }

      final result = await remoteDataSource.addSubscription(subscriptionModel);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Subscription>> updateSubscription(
    Subscription subscription,
  ) async {
    try {
      final subscriptionModel = SubscriptionModel.fromEntity(subscription);
      final result =
          await remoteDataSource.updateSubscription(subscriptionModel);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSubscription(
      String subscriptionId) async {
    try {
      await remoteDataSource.deleteSubscription(subscriptionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Subscription>>> getSubscriptions(
    String userId,
  ) async {
    try {
      final subscriptions = await remoteDataSource.getSubscriptions(userId);
      return Right(subscriptions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Subscription>>> getActiveSubscriptions(
    String userId,
  ) async {
    try {
      final subscriptions =
          await remoteDataSource.getActiveSubscriptions(userId);
      return Right(subscriptions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Subscription>> getSubscriptionById(
    String subscriptionId,
  ) async {
    try {
      final subscription = await remoteDataSource.getSubscriptionById(
        subscriptionId,
      );
      return Right(subscription);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Subscription>>> getSubscriptionsByBillingDate(
    String userId,
    int billingDay,
  ) async {
    try {
      final subscriptions =
          await remoteDataSource.getSubscriptionsByBillingDate(
        userId,
        billingDay,
      );
      return Right(subscriptions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Subscription>>> getSubscriptionsByCategory(
    String userId,
    String category,
  ) async {
    try {
      final subscriptions = await remoteDataSource.getSubscriptionsByCategory(
        userId,
        category,
      );
      return Right(subscriptions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createExpenseFromSubscription(
    SubscriptionModel subscription,
  ) async {
    try {
      await remoteDataSource.createExpenseFromSubscription(subscription);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
