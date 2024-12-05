import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:finpal/presentation/bloc/expense/expense_bloc.dart';
import 'package:finpal/presentation/bloc/expense/expense_state.dart';
import 'package:finpal/presentation/pages/expense/widget/budget_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class MonthlySummaryCard extends StatelessWidget {
  const MonthlySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is! ExpenseLoaded) {
          return const SizedBox.shrink();
        }

        // 현재 유저의 통화 설정 가져오기
        final userCurrency = context.read<AppSettingsBloc>().state.currency;

        // 통화별 총액 계산
        final totalsByCurrency = <String, double>{};
        for (var expense in state.expenses) {
          if (_isCurrentMonth(expense.date)) {
            totalsByCurrency.update(
              expense.currency,
              (value) => value + expense.amount,
              ifAbsent: () => expense.amount,
            );
          }
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getLocalizedLabel(context, 'monthly_expenses'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getLocalizedMonth(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...totalsByCurrency.entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key, // 통화 코드
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _formatAmount(entry.value, entry.key),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )),
                if (state.monthlyBudget > 0) ...[
                  const Divider(color: Colors.white24, height: 32),
                  _buildBudgetProgress(context, state, userCurrency),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBudgetProgress(
      BuildContext context, ExpenseLoaded state, String currency) {
    final totalExpenses = state.expenses
        .where((e) => _isCurrentMonth(e.date) && e.currency == currency)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    final progress = totalExpenses / state.monthlyBudget;
    final isOverBudget = progress > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getLocalizedLabel(context, 'budget_remaining'),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            Text(
              _formatAmount(state.monthlyBudget - totalExpenses, currency),
              style: TextStyle(
                color: isOverBudget ? Colors.red[300] : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(
              isOverBudget ? Colors.red[300]! : Colors.green[300]!,
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, Map<String, String>> labels = {
      AppLanguage.english: {
        'monthly_expenses': 'This Month\'s Expenses',
        'budget_remaining': 'Budget Remaining',
      },
      AppLanguage.korean: {
        'monthly_expenses': '이번 달 지출',
        'budget_remaining': '예산 남은 금액',
      },
      AppLanguage.japanese: {
        'monthly_expenses': '今月の支出',
        'budget_remaining': '予算残高',
      },
    };
    return labels[language]?[key] ?? labels[AppLanguage.korean]![key]!;
  }

  String _formatAmount(double amount, String currency) {
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

  bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  String _getLocalizedMonth(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    final now = DateTime.now();

    switch (language) {
      case AppLanguage.english:
        return DateFormat('MMMM').format(now); // "January", "February" etc.
      case AppLanguage.japanese:
        return DateFormat('M月').format(now); // "1月", "2月" etc.
      case AppLanguage.korean:
      default:
        return DateFormat('MM월').format(now); // "01월", "02월" etc.
    }
  }
}
