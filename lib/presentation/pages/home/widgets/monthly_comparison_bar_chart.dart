import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/expense/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/expense/expense_bloc.dart';
import 'package:intl/intl.dart';

class MonthlyComparisonBarChart extends StatelessWidget {
  const MonthlyComparisonBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is! ExpenseLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = state.categoryTotals.keys.toList();
        final currentMonthData = state.categoryTotals;
        final previousMonthData = state.previousMonthCategoryTotals;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                _getLocalizedTitle(context),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxValue(currentMonthData, previousMonthData),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value < 0 || value >= categories.length) {
                              return const SizedBox();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _getLocalizedCategory(
                                    context, categories[value.toInt()]),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              _getLocalizedAmount(context, value),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: _createBarGroups(
                      categories,
                      currentMonthData,
                      previousMonthData,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendItem(
                    color: Colors.blue,
                    label: _getLocalizedCurrentMonth(context),
                  ),
                  const SizedBox(width: 16),
                  _LegendItem(
                    color: Colors.grey,
                    label: _getLocalizedPreviousMonth(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Expense Comparison by Category',
      AppLanguage.korean: '카테고리별 지출 비교',
      AppLanguage.japanese: 'カテゴリー別支出比較',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedCategory(BuildContext context, String category) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> categories = {
      'food': {
        AppLanguage.english: 'Food',
        AppLanguage.korean: '식비',
        AppLanguage.japanese: '食費',
      },
      'transport': {
        AppLanguage.english: 'Transport',
        AppLanguage.korean: '교통',
        AppLanguage.japanese: '交通',
      },
      'shopping': {
        AppLanguage.english: 'Shopping',
        AppLanguage.korean: '쇼핑',
        AppLanguage.japanese: '買物',
      },
      'entertainment': {
        AppLanguage.english: 'Entertainment',
        AppLanguage.korean: '여가',
        AppLanguage.japanese: '娯楽',
      },
      'health': {
        AppLanguage.english: 'Medical',
        AppLanguage.korean: '의료',
        AppLanguage.japanese: '医療',
      },
      'beauty': {
        AppLanguage.english: 'Beauty',
        AppLanguage.korean: '미용',
        AppLanguage.japanese: '美容',
      },
      'utilities': {
        AppLanguage.english: 'Utilities',
        AppLanguage.korean: '공과금',
        AppLanguage.japanese: '公共料金',
      },
      'education': {
        AppLanguage.english: 'Education',
        AppLanguage.korean: '교육',
        AppLanguage.japanese: '教育',
      },
      'savings': {
        AppLanguage.english: 'Savings',
        AppLanguage.korean: '저축',
        AppLanguage.japanese: '貯蓄',
      },
      'travel': {
        AppLanguage.english: 'Travel',
        AppLanguage.korean: '여행',
        AppLanguage.japanese: '旅行',
      },
      'others': {
        AppLanguage.english: 'Others',
        AppLanguage.korean: '기타',
        AppLanguage.japanese: 'その他',
      },
    };
    return categories[category]?[language] ?? category;
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

  String _getLocalizedCurrentMonth(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> labels = {
      AppLanguage.english: 'This Month',
      AppLanguage.korean: '이번 달',
      AppLanguage.japanese: '今月',
    };
    return labels[language] ?? labels[AppLanguage.korean]!;
  }

  String _getLocalizedPreviousMonth(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> labels = {
      AppLanguage.english: 'Last Month',
      AppLanguage.korean: '지난 달',
      AppLanguage.japanese: '先月',
    };
    return labels[language] ?? labels[AppLanguage.korean]!;
  }

  double _getMaxValue(
    Map<String, double> currentData,
    Map<String, double> previousData,
  ) {
    double max = 0;
    currentData.values.forEach((value) {
      if (value > max) max = value;
    });
    previousData.values.forEach((value) {
      if (value > max) max = value;
    });
    return max * 1.2; // 20% 여유 공간
  }

  List<BarChartGroupData> _createBarGroups(
    List<String> categories,
    Map<String, double> currentData,
    Map<String, double> previousData,
  ) {
    return List.generate(categories.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: currentData[categories[index]] ?? 0,
            color: Colors.blue,
            width: 12,
          ),
          BarChartRodData(
            toY: previousData[categories[index]] ?? 0,
            color: Colors.grey,
            width: 12,
          ),
        ],
      );
    });
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
