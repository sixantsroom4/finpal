import 'package:finpal/presentation/bloc/expense/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/expense/expense_bloc.dart';
import 'package:intl/intl.dart';

class MonthlyTrendLineChart extends StatelessWidget {
  const MonthlyTrendLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is! ExpenseLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final now = DateTime.now();
        final monthlyTotals = state.monthlyTotals;
        final spots = _createSpots(monthlyTotals);
        final maxY = _getMaxY(spots) * 1.2;

        return Column(
          children: [
            const Text(
              '월별 지출 추이',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final month = DateTime(
                              now.year,
                              now.month - value.toInt(),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('M월').format(month),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: value == 0
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                                ),
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
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 4,
                    minY: 0,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 2,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: spot.x == 0
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<FlSpot> _createSpots(Map<String, double> monthlyTotals) {
    final spots = <FlSpot>[];
    final now = DateTime.now();

    // 현재 월의 키 생성
    final currentMonthKey = DateFormat('yyyy-MM').format(now);

    // X축 위치 (0부터 4까지)
    for (int i = 0; i < 5; i++) {
      final month = DateTime(now.year, now.month - i);
      final key = DateFormat('yyyy-MM').format(month);

      // 현재 월의 데이터만 실제 값을 사용하고, 나머지는 0으로 표시
      final amount = key == currentMonthKey ? monthlyTotals[key] ?? 0.0 : 0.0;
      spots.add(FlSpot(i.toDouble(), amount.toDouble()));
    }

    return spots;
  }

  double _getMaxY(List<FlSpot> spots) {
    double maxY = 0;
    for (var spot in spots) {
      if (spot.y > maxY) maxY = spot.y;
    }
    return maxY == 0 ? 100000 : maxY;
  }
}
