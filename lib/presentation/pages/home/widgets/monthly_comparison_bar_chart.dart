import 'package:finpal/presentation/bloc/expense/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/expense/expense_bloc.dart';

class MonthlyComparisonBarChart extends StatelessWidget {
  const MonthlyComparisonBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is! ExpenseLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
                // 막대 차트 구현
                // 카테고리별 이전 달과 이번 달 비교
                ),
          ),
        );
      },
    );
  }
}
