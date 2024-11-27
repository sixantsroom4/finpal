import 'package:finpal/core/utils/constants.dart';
import 'package:finpal/presentation/bloc/expense/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../bloc/expense/expense_bloc.dart';
import '../../../bloc/app_language/app_language_bloc.dart';
import '../../../../core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';

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
      'productivity': {
        AppLanguage.english: 'Productivity',
        AppLanguage.korean: '생산성',
        AppLanguage.japanese: '生産性',
      },
      'software': {
        AppLanguage.english: 'Software',
        AppLanguage.korean: '소프트웨어',
        AppLanguage.japanese: 'ソフトウェア',
      },
      'pet_care': {
        AppLanguage.english: 'Pet Care',
        AppLanguage.korean: '반려동물 관리',
        AppLanguage.japanese: 'ペットケア',
      },
      'beauty': {
        AppLanguage.english: 'Beauty',
        AppLanguage.korean: '뷰티',
        AppLanguage.japanese: '美容',
      },
      'car_services': {
        AppLanguage.english: 'Car Services',
        AppLanguage.korean: '자동차 서비스',
        AppLanguage.japanese: '車サービス',
      },
      'streaming': {
        AppLanguage.english: 'Streaming Services',
        AppLanguage.korean: '스트리밍 서비스',
        AppLanguage.japanese: 'ストリーミングサービス',
      },
      'rent': {
        AppLanguage.english: 'Rent',
        AppLanguage.korean: '월세',
        AppLanguage.japanese: '家賃',
      },
      'delivery': {
        AppLanguage.english: 'Delivery Services',
        AppLanguage.korean: '배송 서비스',
        AppLanguage.japanese: '配送サービス',
      },
      'premium': {
        AppLanguage.english: 'Premium Memberships',
        AppLanguage.korean: '프리미엄 멤버십',
        AppLanguage.japanese: 'プレミアム会員',
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
    final currency = context.read<AppSettingsBloc>().state.currency;
    final formattedAmount = NumberFormat('#,###').format(amount);

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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _getLocalizedAmount(context, amount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value,
      {bool isCurrency = false}) {
    if (isCurrency) {
      final currency = context.read<AppSettingsBloc>().state.currency;
      final amount = double.parse(value.replaceAll(RegExp(r'[^0-9.]'), ''));

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
          value = '$symbol${NumberFormat('#,###').format(amount)}';
          break;
        case 'JPY':
          value = '¥${NumberFormat('#,###').format(amount)}';
          break;
        case 'KRW':
        default:
          value = '${NumberFormat('#,###').format(amount)}$symbol';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
