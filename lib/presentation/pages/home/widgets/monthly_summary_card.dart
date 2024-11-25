import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:finpal/presentation/bloc/expense/expense_bloc.dart';
import 'package:finpal/presentation/bloc/expense/expense_state.dart';
import 'package:finpal/presentation/pages/expense/widget/budget_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MonthlySummaryCard extends StatelessWidget {
  const MonthlySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is! ExpenseLoaded) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final monthlyBudget = state.monthlyBudget;

        if (monthlyBudget <= 0) {
          return Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLocalizedTitle(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getLocalizedAmount(context, state.totalAmount),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BudgetSettingsPage(),
                        ),
                      );
                    },
                    child: Text(_getLocalizedSetBudgetButton(context)),
                  ),
                ],
              ),
            ),
          );
        }

        final remainingBudget = monthlyBudget - state.totalAmount;
        final spendingRatio = state.totalAmount / monthlyBudget;

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLocalizedTitle(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getLocalizedAmount(context, state.totalAmount),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: spendingRatio.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    state.totalAmount > monthlyBudget
                        ? Colors.red
                        : Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getLocalizedRemainingBudget(context, remainingBudget),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'This Month\'s Expenses',
      AppLanguage.korean: '이번 달 지출',
      AppLanguage.japanese: '今月の支出',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedAmount(BuildContext context, double amount) {
    final currency = context.read<AppSettingsBloc>().state.currency;
    final formattedAmount = amount.toStringAsFixed(0);

    final currencySymbols = {
      'KRW': '원',
      'JPY': '¥',
      'USD': '\$',
      'EUR': '€',
    };

    final symbol = currencySymbols[currency] ?? currencySymbols['KRW']!;

    // 통화별 표시 형식
    switch (currency) {
      case 'USD':
      case 'EUR':
        return '$symbol$formattedAmount';
      case 'JPY':
        return '¥$formattedAmount';
      case 'KRW':
      default:
        return '$formattedAmount$symbol';
    }
  }

  String _getLocalizedSetBudgetButton(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> buttons = {
      AppLanguage.english: 'Set Monthly Budget',
      AppLanguage.korean: '월 예산을 설정해주세요',
      AppLanguage.japanese: '月予算を設定してください',
    };
    return buttons[language] ?? buttons[AppLanguage.korean]!;
  }

  String _getLocalizedRemainingBudget(BuildContext context, double remaining) {
    final language = context.read<AppLanguageBloc>().state.language;
    final currency = context.read<AppSettingsBloc>().state.currency;
    final formattedRemaining = remaining.toStringAsFixed(0);

    final currencySymbols = {
      'KRW': '원',
      'JPY': '¥',
      'USD': '\$',
      'EUR': '€',
    };

    final symbol = currencySymbols[currency] ?? currencySymbols['KRW']!;

    final Map<AppLanguage, String Function(String, String)> messages = {
      AppLanguage.english: (amount, symbol) =>
          '$symbol$amount remaining in budget',
      AppLanguage.korean: (amount, symbol) => '월 예산까지 $amount$symbol 남았습니다',
      AppLanguage.japanese: (amount, symbol) => '月予算まで$symbol$amount残っています',
    };

    return messages[language]?.call(formattedRemaining, symbol) ??
        messages[AppLanguage.korean]!.call(formattedRemaining, symbol);
  }
}
