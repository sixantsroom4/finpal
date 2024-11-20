import 'package:finpal/presentation/bloc/expense/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/expense/expense_bloc.dart';

class MonthlyTrendLineChart extends StatelessWidget {
  const MonthlyTrendLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is! ExpenseLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: LineChart(
            LineChartData(
                // 꺾은선 차트 구현
                // 최근 6개월 총 지출 추이
                ),
          ),
        );
      },
    );
  }
}
