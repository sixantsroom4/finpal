// lib/core/services/injection_container.dart
import 'package:finpal/data/datasources/remote/firebase_storage_remote_data_source.dart';
import 'package:finpal/data/datasources/remote/firebase_storage_remote_data_source_impl.dart';
import 'package:finpal/data/datasources/remote/gemini_remote_data_source.dart';
import 'package:finpal/data/repositories/receipt_repository_impl.dart';
import 'package:finpal/domain/repositories/receipt_repository.dart';
import 'package:finpal/domain/usecases/receipt/upload_receipt_usecase.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'injection_container.main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final googleSignIn = GoogleSignIn();

  sl.registerLazySingleton(() => firebaseAuth);
  sl.registerLazySingleton(() => firestore);
  sl.registerLazySingleton(() => storage);
  sl.registerLazySingleton(() => googleSignIn);

  // Gemini
  final geminiApi = GenerativeModel(
    model: 'gemini-pro-vision',
    apiKey: dotenv.env['GEMINI_API_KEY']!,
  );

  sl.registerLazySingleton<GeminiRemoteDataSource>(
    () => GeminiRemoteDataSourceImpl(
      model: geminiApi,
      apiKey: dotenv.env['GEMINI_API_KEY']!,
    ),
  );

  // Firebase Storage
  sl.registerLazySingleton<FirebaseStorageRemoteDataSource>(
    () => FirebaseStorageRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
      storage: sl<FirebaseStorage>(),
      model: geminiApi,
    ),
  );

  // Receipt Repository
  sl.registerLazySingleton<ReceiptRepository>(
    () => ReceiptRepositoryImpl(
      storageDataSource: sl(),
      geminiDataSource: sl(),
    ),
  );

  // Receipt UseCase
  sl.registerLazySingleton(() => UploadReceiptUseCase(sl()));

  // Receipt Bloc
  sl.registerFactory(
    () => ReceiptBloc(
      receiptRepository: sl(),
    ),
  );

  // Main initialization
  await initMain();
}
