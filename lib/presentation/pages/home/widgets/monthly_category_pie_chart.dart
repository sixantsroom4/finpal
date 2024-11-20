import 'package:finpal/presentation/bloc/expense/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/expense/expense_bloc.dart';

class MonthlyCategoryPieChart extends StatelessWidget {
  const MonthlyCategoryPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is! ExpenseLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            const SizedBox(height: 24),
            // 원형 차트 (중앙 배치)
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _createPieChartSections(state.categoryTotals),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // 범례 (아래에 배치)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildLegend(
                state.categoryTotals,
                state.totalAmount,
              ),
            ),
          ],
        );
      },
    );
  }

  List<PieChartSectionData> _createPieChartSections(
      Map<String, double> categoryTotals) {
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

  Widget _buildLegend(Map<String, double> categoryTotals, double totalAmount) {
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categoryTotals.entries.toList().asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value.key;
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
                '${amount.toStringAsFixed(0)}원',
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
