// lib/core/services/injection_container.dart
import 'package:finpal/data/datasources/remote/firebase_storage_remote_data_source.dart';
import 'package:finpal/data/datasources/remote/firebase_storage_remote_data_source_impl.dart';
import 'package:finpal/data/datasources/remote/gemini_remote_data_source.dart';
import 'package:finpal/data/repositories/receipt_repository_impl.dart';
import 'package:finpal/domain/repositories/receipt_repository.dart';
import 'package:finpal/domain/usecases/receipt/upload_receipt_usecase.dart';
import 'package:finpal/firebase_options.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finpal/domain/repositories/auth_repository.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:finpal/presentation/bloc/customer_service/customer_service_bloc.dart';
import 'package:finpal/domain/repositories/customer_service_repository.dart';
import 'package:finpal/data/repositories/customer_service_repository_impl.dart';
import 'package:finpal/core/services/notion_service.dart';
import 'package:firebase_core/firebase_core.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Firebase 초기화
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // External - 중복 등록 방지
  if (!sl.isRegistered<FirebaseAuth>()) {
    sl.registerLazySingleton(() => FirebaseAuth.instance);
  }
  if (!sl.isRegistered<FirebaseFirestore>()) {
    sl.registerLazySingleton(() => FirebaseFirestore.instance);
  }
  if (!sl.isRegistered<FirebaseStorage>()) {
    sl.registerLazySingleton(() => FirebaseStorage.instance);
  }
  if (!sl.isRegistered<GoogleSignIn>()) {
    sl.registerLazySingleton(() => GoogleSignIn());
  }

  // Gemini
  final geminiApi = GenerativeModel(
    model: 'gemini-pro-vision',
    apiKey: dotenv.env['GEMINI_API_KEY']!,
  );

  // GeminiRemoteDataSource 중복 등록 방지
  if (!sl.isRegistered<GeminiRemoteDataSource>()) {
    sl.registerLazySingleton<GeminiRemoteDataSource>(
      () => GeminiRemoteDataSourceImpl(
        model: geminiApi,
        apiKey: dotenv.env['GEMINI_API_KEY']!,
      ),
    );
  }

  // Firebase Storage 중복 등록 방지
  if (!sl.isRegistered<FirebaseStorageRemoteDataSource>()) {
    sl.registerLazySingleton<FirebaseStorageRemoteDataSource>(
      () => FirebaseStorageRemoteDataSourceImpl(
        firestore: sl<FirebaseFirestore>(),
        storage: sl<FirebaseStorage>(),
        model: geminiApi,
      ),
    );
  }

  // Receipt Repository 중복 등록 방지
  if (!sl.isRegistered<ReceiptRepository>()) {
    sl.registerLazySingleton<ReceiptRepository>(
      () => ReceiptRepositoryImpl(
        storageDataSource: sl(),
        geminiDataSource: sl(),
      ),
    );
  }

  // Receipt UseCase 중복 등록 방지
  if (!sl.isRegistered<UploadReceiptUseCase>()) {
    sl.registerLazySingleton(() => UploadReceiptUseCase(sl()));
  }

  // Receipt Bloc 중복 등록 방지
  if (!sl.isRegistered<ReceiptBloc>()) {
    sl.registerFactory(
      () => ReceiptBloc(
        receiptRepository: sl(),
      ),
    );
  }

  // AppSettingsBloc 중복 등록 방지
  if (!sl.isRegistered<AppSettingsBloc>()) {
    sl.registerLazySingleton(() => AppSettingsBloc(
          sl<SharedPreferences>(),
          sl<AuthRepository>(),
        ));
  }

  // Services - NotionService 중복 등록 방지
  if (!sl.isRegistered<NotionService>()) {
    sl.registerLazySingleton(() => NotionService());
  }

  // CustomerServiceBloc - NotionService 등록 후에 초기화
  if (!sl.isRegistered<CustomerServiceBloc>()) {
    initCustomerService();
  }

  // Main initialization
  await initMain();
}

void initCustomerService() {
  // Bloc
  sl.registerFactory(
    () => CustomerServiceBloc(
      repository: sl(),
      notionService: sl(),
    ),
  );

  // Repository
  if (!sl.isRegistered<CustomerServiceRepository>()) {
    sl.registerLazySingleton<CustomerServiceRepository>(
      () => CustomerServiceRepositoryImpl(
        firestore: sl(),
        storage: sl(),
      ),
    );
  }
}
