// lib/core/routes/app_router.dart
import 'dart:async';

import 'package:finpal/presentation/pages/expense/widget/budget_settings_page.dart';
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

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      debugLogDiagnostics: true,
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        debugPrint('라우팅 리다이렉트 시도:');
        debugPrint('현재 경로: ${state.uri.path}');
        debugPrint('인증 상태: $authState');

        // 로딩 상태일 때는 리다이렉트하지 않음
        if (authState is AuthLoading) {
          debugPrint('로딩 중 - 리다이렉트 없음');
          return null;
        }

        final isAuthenticated = authState is Authenticated;
        final isAuthRoute = state.uri.path == '/welcome';

        if (!isAuthenticated) {
          debugPrint('미인증 상태 - /welcome으로 리다이렉트');
          return '/welcome';
        }

        if (isAuthenticated && isAuthRoute) {
          debugPrint('인증된 상태에서 인증 페이지 접근 - /로 리다이렉트');
          return '/';
        }

        debugPrint('리다이렉트 없음');
        return null;
      },
      routes: [
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomePage(),
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
            ),
            GoRoute(
              path: '/receipts/:id',
              builder: (context, state) => ReceiptDetailsPage(
                receiptId: state.pathParameters['id']!,
              ),
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
            ),
            GoRoute(
              path: '/settings/budget',
              builder: (context, state) => const BudgetSettingsPage(),
            ),
          ],
        ),
      ],
    );
  }
}

class ScaffoldWithNavigationBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavigationBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: '지출',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner),
            label: '영수증',
          ),
          NavigationDestination(
            icon: Icon(Icons.subscriptions_outlined),
            selectedIcon: Icon(Icons.subscriptions),
            label: '구독',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '프로필',
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
