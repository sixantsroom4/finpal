import 'package:finpal/core/utils/constants.dart';
import 'package:finpal/presentation/bloc/expense/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../bloc/expense/expense_bloc.dart';
import '../../../bloc/app_language/app_language_bloc.dart';
import '../../../../core/constants/app_languages.dart';

class MonthlyCategoryPieChart extends StatelessWidget {
  const MonthlyCategoryPieChart({super.key});

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'no_expenses': {
        AppLanguage.english: 'No expenses this month',
        AppLanguage.korean: '이번 달 지출 내역이 없습니다.',
        AppLanguage.japanese: '今月の支出履歴がありません',
      },
      'ott': {
        AppLanguage.english: 'OTT',
        AppLanguage.korean: 'OTT',
        AppLanguage.japanese: 'OTT',
      },
      'music': {
        AppLanguage.english: 'Music',
        AppLanguage.korean: '음악',
        AppLanguage.japanese: '音楽',
      },
      'game': {
        AppLanguage.english: 'Game',
        AppLanguage.korean: '게임',
        AppLanguage.japanese: 'ゲーム',
      },
      'fitness': {
        AppLanguage.english: 'Fitness',
        AppLanguage.korean: '피트니스',
        AppLanguage.japanese: 'フィットネス',
      },
      'other': {
        AppLanguage.english: 'Other',
        AppLanguage.korean: '기타',
        AppLanguage.japanese: 'その他',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  String _getLocalizedAmount(BuildContext context, double amount) {
    final language = context.read<AppLanguageBloc>().state.language;
    final formattedAmount = NumberFormat('#,###').format(amount);
    switch (language) {
      case AppLanguage.english:
        return '\$$formattedAmount';
      case AppLanguage.japanese:
        return '¥$formattedAmount';
      case AppLanguage.korean:
      default:
        return '${formattedAmount}원';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is! ExpenseLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final now = DateTime.now();
        final currentMonthCategoryTotals = <String, double>{};

        for (final expense in state.expenses) {
          if (expense.date.year == now.year &&
              expense.date.month == now.month) {
            currentMonthCategoryTotals[expense.category] =
                (currentMonthCategoryTotals[expense.category] ?? 0) +
                    expense.amount;
          }
        }

        if (currentMonthCategoryTotals.isEmpty) {
          return Center(
            child: Text(_getLocalizedLabel(context, 'no_expenses')),
          );
        }

        return Column(
          children: [
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _createPieChartSections(
                        context, currentMonthCategoryTotals),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildLegend(
                context,
                currentMonthCategoryTotals,
                currentMonthCategoryTotals.values
                    .fold(0.0, (sum, amount) => sum + amount),
              ),
            ),
          ],
        );
      },
    );
  }

  List<PieChartSectionData> _createPieChartSections(
      BuildContext context, Map<String, double> categoryTotals) {
    final total =
        categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    final colors = [
      const Color(0xFF5C6BC0),
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    return categoryTotals.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final amount = entry.value.value;
      final percentage = (amount / total * 100);

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: amount,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(BuildContext context, Map<String, double> categoryTotals,
      double totalAmount) {
    final colors = [
      const Color(0xFF5C6BC0),
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    final language = context.read<AppLanguageBloc>().state.language;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categoryTotals.entries.toList().asMap().entries.map((entry) {
        final index = entry.key;
        final category =
            CategoryConstants.getLocalizedCategory(entry.value.key, language);
        final amount = entry.value.value;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _getLocalizedAmount(context, amount),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
