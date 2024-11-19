// lib/core/services/injection_container.main.dart
import 'package:finpal/data/datasources/remote/firebase_storage_remote_data_source_impl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/expense/expense_bloc.dart';
import '../../presentation/bloc/receipt/receipt_bloc.dart';
import '../../presentation/bloc/subscription/subscription_bloc.dart';
import '../../data/datasources/remote/firebase_auth_remote_data_source.dart';
import '../../data/datasources/remote/firebase_storage_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../data/repositories/receipt_repository_impl.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../../domain/repositories/subscription_repository.dart';
import 'injection_container.dart';

Future<void> initMain() async {
  // Data sources
  sl.registerLazySingleton<FirebaseAuthRemoteDataSource>(
    () => FirebaseAuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
      firestore: sl(),
    ),
  );

  // 이미 등록되어 있지 않은 경우에만 등록
  if (!sl.isRegistered<FirebaseStorageRemoteDataSource>()) {
    sl.registerLazySingleton<FirebaseStorageRemoteDataSource>(
      () => FirebaseStorageRemoteDataSourceImpl(
        firestore: sl(),
        storage: sl(),
        model: sl(),
      ),
    );
  }

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Blocs
  sl.registerFactory(() => AuthBloc(
        authRepository: sl(),
      ));

  sl.registerFactory(() => ExpenseBloc(
        expenseRepository: sl(),
      ));

  sl.registerFactory(() => SubscriptionBloc(
        subscriptionRepository: sl(),
      ));
}
