// lib/main.dart
import 'package:finpal/core/services/injection_container.dart';
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
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/utils/firebase_migration_utils.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart'; // 추가
import 'package:flutter_localizations/flutter_localizations.dart'; // 추가

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // intl 로케일 데이터 초기화
  await initializeDateFormatting(); // 모든 로케일 데이터 초기화

  await init();
  debugPrint('Flutter binding initialized');

  // 화면 방향을 세로 모드로 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    // DeviceOrientation.portraitDown,  // 필요 시
    // DeviceOrientation.landscapeLeft,  // 필요 시
    // DeviceOrientation.landscapeRight,
  ]);

  Bloc.observer = AppBlocObserver();
  debugPrint('BlocObserver registered');

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

  // 사용자 인증 상태 확인을 위해 기다림
  await Future.delayed(const Duration(seconds: 2));

  // 현재 사용자 확인
  final currentUser = FirebaseAuth.instance.currentUser;
  debugPrint('Current user: ${currentUser?.uid ?? 'Not logged in'}');

  // Firebase Auth 초기화 확인
  FirebaseAuth.instance.authStateChanges().listen((firebaseUser) {
    if (firebaseUser == null) {
      debugPrint('사용자가 로그아웃 상태입니다');
    } else {
      debugPrint('사용자가 로그인 상태입니다: ${firebaseUser.uid}');
    }
  });

  // 사용자가 로그인된 경우에만 마이그레이션 실행
  if (currentUser != null) {
    debugPrint('마이그레이션 시작...');
    await FirebaseMigrationUtils.runMigrations();
    debugPrint('마이그레이션 완료');
  } else {
    debugPrint('마이그레이션 건너뜀: 사용자가 로그인되지 않음');
  }

  runApp(
    Phoenix(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<AppLanguageBloc>(
              create: (_) => di.sl<AppLanguageBloc>()),
          BlocProvider<UserRegistrationBloc>(
              create: (_) => di.sl<UserRegistrationBloc>()),
          BlocProvider<AppSettingsBloc>(
              create: (_) => di.sl<AppSettingsBloc>()),
        ],
        child: MyApp(authBloc: authBloc),
      ),
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
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
          ),
          routerConfig: AppRouter.router(authBloc),
          debugShowCheckedModeBanner: false,
          // 로컬라이제이션 설정 추가
          supportedLocales: const [
            Locale('en'), // 영어
            Locale('ja'), // 일본어
            Locale('ko'), // 한국어
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                debugPrint('현재 인 상태: $state');
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
