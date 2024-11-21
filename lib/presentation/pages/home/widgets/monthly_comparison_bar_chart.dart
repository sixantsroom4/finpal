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
              const Text(
                '카테고리별 지출 비교',
                style: TextStyle(
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
                                categories[value.toInt()],
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
                              NumberFormat('#,###').format(value),
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
                    label: '이번 달',
                  ),
                  const SizedBox(width: 16),
                  _LegendItem(
                    color: Colors.grey,
                    label: '지난 달',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
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
