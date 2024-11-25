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
          amount: 0.0, // 이 값은 무시되고 Firebase에서 실제 값을 가져옵니다
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinPal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! Authenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_getLocalizedLoginMessage(context)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthGoogleSignInRequested());
                    },
                    child: Text(_getLocalizedGoogleSignIn(context)),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLocalizedGreeting(context, state.user.displayName),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    const MonthlySummaryCard(),
                    const SizedBox(height: 16),
                    const ExpenseChartsView(),
                    const SizedBox(height: 16),
                    const UpcomingSubscriptionsCard(),
                    // const SizedBox(height: 16),
                    // const RecentExpensesList(),
                  ],
                ),
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
