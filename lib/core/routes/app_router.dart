// lib/core/routes/app_router.dart
import 'dart:async';

import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/domain/entities/receipt.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/pages/expense/widget/add_expense_bottom_sheet.dart';
import 'package:finpal/presentation/pages/expense/widget/budget_settings_page.dart';
import 'package:finpal/presentation/pages/onboarding/terms_page.dart';
import 'package:finpal/presentation/pages/receipt/receipt_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/auth/auth_state.dart';
import '../../presentation/pages/auth/welcome_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/expense/expense_page.dart';
import '../../presentation/pages/receipt/receipt_page.dart';
import '../../presentation/pages/subscription/subscription_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/common/loading_page.dart';
import '../../presentation/pages/settings/account/account_settings_page.dart';
import '../../presentation/pages/user_registration/user_registration_page.dart';
import '../../presentation/pages/customer_service/customer_service_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      debugLogDiagnostics: true,
      initialLocation: '/expenses',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      routes: [
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomePage(),
        ),
        GoRoute(
          path: '/terms',
          builder: (context, state) => const TermsPage(),
        ),
        GoRoute(
          path: '/registration',
          builder: (context, state) => const UserRegistrationPage(),
        ),
        ShellRoute(
          builder: (context, state, child) =>
              ScaffoldWithNavigationBar(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: '/expenses',
              builder: (context, state) => const ExpensePage(),
            ),
            GoRoute(
              path: '/receipts',
              builder: (context, state) => const ReceiptPage(),
              routes: [
                GoRoute(
                  path: ':receiptId',
                  builder: (context, state) {
                    final receiptId = state.pathParameters['receiptId'];
                    return ReceiptDetailsPage(receiptId: receiptId!);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/subscriptions',
              builder: (context, state) => const SubscriptionPage(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
              routes: [
                GoRoute(
                  path: 'budget',
                  builder: (context, state) => const BudgetSettingsPage(),
                ),
                GoRoute(
                  path: 'account',
                  builder: (context, state) => const AccountSettingsPage(),
                ),
                GoRoute(
                  path: 'customer-service',
                  builder: (context, state) => const CustomerServicePage(),
                ),
              ],
            ),
            GoRoute(
              path: '/add-expense',
              builder: (context, state) => const AddExpenseBottomSheet(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        if (state.uri.path == '/home') {
          return '/';
        }

        final authState = authBloc.state;
        debugPrint('라우팅 리다이렉트 시도:');
        debugPrint('현재 경로: ${state.uri.path}');
        debugPrint('인증 상태: $authState');

        final isWelcomeRoute = state.uri.path == '/welcome';
        final isTermsRoute = state.uri.path == '/terms';
        final isRegistrationRoute = state.uri.path == '/registration';

        // 인증되지 않은 사용자는 welcome 페이지로
        if (authState is Unauthenticated) {
          if (!isWelcomeRoute) {
            debugPrint('미인증 상태 - /welcome으로 리다이렉트');
            return '/welcome';
          }
          return null;
        }

        // 인증된 사용자의 약관 동의 여부 확인
        if (authState is Authenticated && !authState.user.hasAcceptedTerms) {
          if (!isTermsRoute) {
            debugPrint('약관 동의 필요 - /terms로 리다이렉트');
            return '/terms';
          }
          return null;
        }

        // 사용자 등록이 필요한 경우
        if (authState is AuthRequiresRegistration) {
          if (!isRegistrationRoute) {
            debugPrint('유저 등록 필요 - /registration으로 리다이렉트');
            return '/registration';
          }
          return null;
        }

        // 인증이 완료된 사용자가 welcome, terms, registration 페이지에 접근하려고 할 때
        if (authState is Authenticated && authState.user.hasAcceptedTerms) {
          if (isWelcomeRoute || isTermsRoute || isRegistrationRoute) {
            debugPrint('인증 완료된 사용자 - 홈으로 리다이렉트');
            return '/';
          }
        }

        return null;
      },
    );
  }
}

class ScaffoldWithNavigationBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavigationBar({
    super.key,
    required this.child,
  });

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'home': {
        AppLanguage.english: 'Home',
        AppLanguage.korean: '홈',
        AppLanguage.japanese: 'ホーム',
      },
      'expenses': {
        AppLanguage.english: 'Expenses',
        AppLanguage.korean: '지출',
        AppLanguage.japanese: '支出',
      },
      'receipts': {
        AppLanguage.english: 'Receipts',
        AppLanguage.korean: '영수증',
        AppLanguage.japanese: 'レシート',
      },
      'subscriptions': {
        AppLanguage.english: 'Subscriptions',
        AppLanguage.korean: '구독',
        AppLanguage.japanese: 'サブスク',
      },
      'profile': {
        AppLanguage.english: 'Profile',
        AppLanguage.korean: '프로필',
        AppLanguage.japanese: 'プロフィール',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/expenses');
              break;
            case 2:
              context.go('/receipts');
              break;
            case 3:
              context.go('/subscriptions');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        selectedIndex: _calculateSelectedIndex(context),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: _getLocalizedLabel(context, 'home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: _getLocalizedLabel(context, 'expenses'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.document_scanner_outlined),
            selectedIcon: const Icon(Icons.document_scanner),
            label: _getLocalizedLabel(context, 'receipts'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.subscriptions_outlined),
            selectedIcon: const Icon(Icons.subscriptions),
            label: _getLocalizedLabel(context, 'subscriptions'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: _getLocalizedLabel(context, 'profile'),
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/expenses')) return 1;
    if (location.startsWith('/receipts')) return 2;
    if (location.startsWith('/subscriptions')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
