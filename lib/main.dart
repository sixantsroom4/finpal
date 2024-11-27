// lib/main.dart
import 'package:finpal/domain/repositories/auth_repository.dart';
import 'package:finpal/presentation/bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_event.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/expense/expense_bloc.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_bloc.dart';
import 'package:finpal/presentation/bloc/subscription/subscription_bloc.dart';
import 'package:finpal/presentation/bloc/user_registration/user_registration_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/injection_container.dart' as di;
import 'core/routes/app_router.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('Flutter binding initialized');

  Bloc.observer = AppBlocObserver();
  debugPrint('BlocObserver registered');

  await dotenv.load(fileName: '.env');
  debugPrint('Environment variables loaded');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Firebase initialized');

  FirebaseStorage.instance.setMaxUploadRetryTime(const Duration(seconds: 3));
  debugPrint('Firebase Storage initialized');

  final prefs = await SharedPreferences.getInstance();
  di.sl.registerLazySingleton(() => prefs);
  debugPrint('SharedPreferences initialized');

  await di.init();
  debugPrint('Dependency injection initialized');

  final authBloc = di.sl<AuthBloc>();
  debugPrint('AuthBloc created: ${identityHashCode(authBloc)}');

  authBloc.add(AuthCheckRequested());
  debugPrint('AuthCheckRequested event added');

  // // 카카오 SDK 초기화
  // KakaoSdk.init(
  //   nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!,
  // );
  // debugPrint('Kakao SDK initialized');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => authBloc),
        BlocProvider<AppLanguageBloc>(create: (_) => di.sl<AppLanguageBloc>()),
        BlocProvider<UserRegistrationBloc>(
            create: (_) => di.sl<UserRegistrationBloc>()),
        BlocProvider<AppSettingsBloc>(create: (_) => di.sl<AppSettingsBloc>()),
      ],
      child: MyApp(authBloc: authBloc),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;

  const MyApp({
    super.key,
    required this.authBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider(create: (_) => di.sl<ExpenseBloc>()),
        BlocProvider(create: (_) => di.sl<SubscriptionBloc>()),
        BlocProvider(create: (_) => di.sl<ReceiptBloc>()),
        BlocProvider<UserRegistrationBloc>(
            create: (_) => di.sl<UserRegistrationBloc>()),
        BlocProvider<AppSettingsBloc>(create: (_) => di.sl<AppSettingsBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          debugPrint('Auth state changed: $state');
        },
        child: MaterialApp.router(
          title: 'FinPal',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          routerConfig: AppRouter.router(authBloc),
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                debugPrint('현재 인증 상태: $state');
                return child ?? const Center(child: Text('화면을 불러 수 없습니다.'));
              },
            );
          },
        ),
      ),
    );
  }
}

// BlocObserver를 추가하여 모든 Bloc 이벤트와 상태 변화를 로깅
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    debugPrint('onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('onChange -- ${bloc.runtimeType}, $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('onError -- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    debugPrint('onClose -- ${bloc.runtimeType}');
  }
}
