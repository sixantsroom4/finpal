// lib/presentation/pages/expense/expense_page.dart
import 'package:finpal/domain/entities/expense.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/expense/expense_event.dart';
import 'package:finpal/presentation/bloc/expense/expense_state.dart';
import 'package:finpal/presentation/pages/expense/widget/add_expense_fab.dart';
import 'package:finpal/presentation/pages/expense/widget/expense_details_bottom_sheet.dart';
import 'package:finpal/presentation/pages/expense/widget/expense_filter_chip.dart';
import 'package:finpal/presentation/pages/expense/widget/monthly_expense_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  String _selectedCategory = '전체';
  final _numberFormat = NumberFormat('#,###');
  final DateTime _now = DateTime.now();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      debugPrint('지출 데이터 로드 시도');
      debugPrint('사용자 ID: ${authState.user.id}');
      debugPrint('시작일: $_startDate');
      debugPrint('종료일: $_endDate');

      context.read<ExpenseBloc>().add(
            LoadExpensesByDateRange(
              userId: authState.user.id,
              startDate: _startDate,
              endDate: _endDate,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지출 내역'),
      ),
      body: Column(
        children: [
          const MonthlyExpenseCard(),
          Expanded(
            child: BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, state) {
                if (state is ExpenseLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ExpenseError) {
                  return Center(child: Text(state.message));
                }

                if (state is! ExpenseLoaded) {
                  return const Center(child: Text('지출 내역이 없습니다.'));
                }

                return Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          ExpenseFilterChip(
                            label: '전체',
                            selected: _selectedCategory == '전체',
                            onSelected: (selected) => _updateCategory('전체'),
                          ),
                          ...state.categoryTotals.keys.map(
                            (category) => ExpenseFilterChip(
                              label: category,
                              selected: _selectedCategory == category,
                              onSelected: (selected) =>
                                  _updateCategory(category),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.expenses.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final expense = state.expenses[index];
                          if (_selectedCategory != '전체' &&
                              expense.category != _selectedCategory) {
                            return const SizedBox.shrink();
                          }

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: Icon(
                                _getCategoryIcon(expense.category),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            title: Text(expense.description),
                            subtitle: Text(
                              DateFormat('M월 d일').format(expense.date),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${_numberFormat.format(expense.amount)}원',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  expense.category,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            onTap: () => _showExpenseDetails(context, expense),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: const AddExpenseFab(),
    );
  }

  void _updateCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(_now.year - 1),
      lastDate: _now,
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadExpenses();
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_bus;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.favorite;
      default:
        return Icons.attach_money;
    }
  }

  void _showExpenseDetails(BuildContext context, Expense expense) {
    // 지출 상세 정보 모달 표시
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ExpenseDetailsBottomSheet(expense: expense),
    );
  }
}
