// lib/presentation/pages/expense/widget/monthly_expense_card.dart
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/expense/expense_event.dart';
import 'package:finpal/presentation/bloc/expense/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../bloc/expense/expense_bloc.dart';
import '../../../bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:finpal/domain/entities/expense.dart';

extension ExpenseListExtension on List<Expense> {
  Map<String, double> groupByCurrency() {
    final totals = <String, double>{};
    for (var expense in this) {
      totals.update(
        expense.currency,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return totals;
  }
}

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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      elevation: 8,
      shadowColor: const Color(0xFF2C3E50).withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2C3E50),
              const Color(0xFF2C3E50).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2C3E50).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      _getLocalizedDate(context, _selectedDate),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white54,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _changeMonth(-1),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_right,
                            color: Colors.white54,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            final nextMonth = DateTime(
                              _selectedDate.year,
                              _selectedDate.month + 1,
                            );
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
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, state) {
                if (state is ExpenseLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is ExpenseLoaded) {
                  final currencyTotals = state.expenses.groupByCurrency();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...currencyTotals.entries
                          .map((entry) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      _getLocalizedAmount(
                                          context, entry.value, entry.key),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getLocalizedDate(BuildContext context, DateTime date) {
    final language = context.read<AppLanguageBloc>().state.language;
    switch (language) {
      case AppLanguage.english:
        return DateFormat('MMMM yyyy').format(date);
      case AppLanguage.japanese:
        return DateFormat('yyyy年 M月').format(date);
      case AppLanguage.korean:
      default:
        return DateFormat('yyyy년 M월').format(date);
    }
  }

  String _getLocalizedExpenseLabel(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> labels = {
      AppLanguage.english: 'Total Expenses',
      AppLanguage.korean: '지출 금액',
      AppLanguage.japanese: '支出金額',
    };
    return labels[language] ?? labels[AppLanguage.korean]!;
  }

  String _getLocalizedAmount(
      BuildContext context, double amount, String currency) {
    final formattedAmount = _numberFormat.format(amount);

    final currencySymbols = {
      'KRW': '원',
      'JPY': '¥',
      'USD': '\$',
      'EUR': '€',
    };

    final symbol = currencySymbols[currency] ?? currency;

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
}
