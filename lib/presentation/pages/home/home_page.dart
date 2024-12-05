// lib/presentation/pages/home/home_page.dart
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_event.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/pages/home/widgets/expense_charts_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import 'widgets/monthly_summary_card.dart';
import 'widgets/recent_expenses_list.dart';
import 'widgets/upcoming_subscriptions_card.dart';
import 'widgets/expense_category_chart.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../../bloc/expense/expense_event.dart';
import '../../bloc/expense/expense_state.dart';
import '../../bloc/subscription/subscription_bloc.dart';
import '../../bloc/subscription/subscription_event.dart';
import '../../bloc/subscription/subscription_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final userId = authState.user.id;

      // 예산과 지출 데이터를 함께 로드
      context.read<ExpenseBloc>()
        ..add(LoadExpenses(userId))
        ..add(UpdateMonthlyBudget(
          userId: userId,
          amount: 0.0,
        ));

      // 구독 데이터 로드 추가
      context.read<SubscriptionBloc>().add(LoadActiveSubscriptions(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        title: const Text(
          'FinPal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => context.go('/settings'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Container(
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getLocalizedLoginMessage(context),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF2C3E50),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthGoogleSignInRequested());
                    },
                    icon: const Icon(Icons.login),
                    label: Text(_getLocalizedGoogleSignIn(context)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // 데이터 로드
          _loadData();

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            color: const Color(0xFF2C3E50),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Text(
                      _getLocalizedGreeting(context, state.user.displayName),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: MonthlySummaryCard(),
                  ),
                  const SizedBox(height: 16),
                  const ExpenseChartsView(),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: UpcomingSubscriptionsCard(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getLocalizedLoginMessage(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> messages = {
      AppLanguage.english: 'Login Required',
      AppLanguage.korean: '로그인이 필요합니다',
      AppLanguage.japanese: 'ログインが必要です',
    };
    return messages[language] ?? messages[AppLanguage.korean]!;
  }

  String _getLocalizedGoogleSignIn(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> buttons = {
      AppLanguage.english: 'Sign in with Google',
      AppLanguage.korean: 'Google로 로그인',
      AppLanguage.japanese: 'Googleでログイン',
    };
    return buttons[language] ?? buttons[AppLanguage.korean]!;
  }

  String _getLocalizedGreeting(BuildContext context, String name) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> greetings = {
      AppLanguage.english: 'Hello, ',
      AppLanguage.korean: '안녕하세요, ',
      AppLanguage.japanese: 'こんにちは、',
    };

    const Map<AppLanguage, String> honorifics = {
      AppLanguage.english: '',
      AppLanguage.korean: '님',
      AppLanguage.japanese: 'さん',
    };

    final greeting = greetings[language] ?? greetings[AppLanguage.korean]!;
    final honorific = honorifics[language] ?? honorifics[AppLanguage.korean]!;

    return '$greeting$name$honorific';
  }
}
