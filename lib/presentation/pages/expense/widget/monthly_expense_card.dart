// lib/presentation/pages/expense/widget/monthly_expense_card.dart
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/expense/expense_event.dart';
import 'package:finpal/presentation/bloc/expense/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../bloc/expense/expense_bloc.dart';
import '../../../bloc/auth/auth_bloc.dart';

class MonthlyExpenseCard extends StatefulWidget {
  const MonthlyExpenseCard({super.key});

  @override
  State<MonthlyExpenseCard> createState() => _MonthlyExpenseCardState();
}

class _MonthlyExpenseCardState extends State<MonthlyExpenseCard> {
  final _numberFormat = NumberFormat('#,###');
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadMonthlyExpenses();
  }

  void _loadMonthlyExpenses() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

      context.read<ExpenseBloc>().add(
            LoadExpensesByDateRange(
              userId: authState.user.id,
              startDate: startDate,
              endDate: endDate,
            ),
          );
    }
  }

  void _changeMonth(int months) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + months,
      );
    });
    _loadMonthlyExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 월 선택 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  DateFormat('yyyy년 M월').format(_selectedDate),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    // 다음 달로 이동 가능하도록 수정
                    final nextMonth = DateTime(
                      _selectedDate.year,
                      _selectedDate.month + 1,
                    );
                    // 현재 달로부터 최대 3개월 후까지만 이동 가능
                    final maxDate = DateTime(
                      DateTime.now().year,
                      DateTime.now().month + 3,
                    );
                    if (nextMonth.isBefore(maxDate) ||
                        nextMonth.isAtSameMomentAs(maxDate)) {
                      _changeMonth(1);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 지출 금액
            BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, state) {
                if (state is ExpenseLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // ExpenseLoaded 상태이거나 다른 상태일 때 모두 금액 표시
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '지출 금액',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${_numberFormat.format(state is ExpenseLoaded ? state.totalAmount : 0)}원',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // 상세 버튼
            SizedBox(
              height: 40,
              child: TextButton(
                onPressed: () {
                  // TODO: 해당 월의 상세 내역 페이지로 이동
                },
                child: const Text('상세'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
