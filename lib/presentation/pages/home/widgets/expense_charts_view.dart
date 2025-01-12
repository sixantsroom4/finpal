import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'monthly_category_pie_chart.dart';
import 'monthly_comparison_bar_chart.dart';
// import 'monthly_trend_line_chart.dart';

class ExpenseChartsView extends StatefulWidget {
  const ExpenseChartsView({super.key});

  @override
  State<ExpenseChartsView> createState() => _ExpenseChartsViewState();
}

class _ExpenseChartsViewState extends State<ExpenseChartsView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getLocalizedTitle(context),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Row(
                children: List.generate(
                  2,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: _currentPage == index
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 400,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: const [
              MonthlyCategoryPieChart(),
              MonthlyComparisonBarChart(),
            ],
          ),
        ),
      ],
    );
  }

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Expense Analysis',
      AppLanguage.korean: '지출 분석',
      AppLanguage.japanese: '支出分析',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }
}
