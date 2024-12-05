// lib/presentation/pages/expense/expense_page.dart
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/domain/entities/expense.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/expense/expense_event.dart';
import 'package:finpal/presentation/bloc/expense/expense_state.dart';
import 'package:finpal/presentation/pages/expense/widget/add_expense_fab.dart';
import 'package:finpal/presentation/pages/expense/widget/expense_details_bottom_sheet.dart';
import 'package:finpal/presentation/pages/expense/widget/expense_filter_chip.dart';
import 'package:finpal/presentation/pages/expense/widget/monthly_expense_card.dart';
import 'package:finpal/presentation/widgets/amount_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/app_language/app_language_bloc.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  String _selectedCategory = '';
  final _numberFormat = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedCategory = _getLocalizedAllCategory(context);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        title: Text(
          _getLocalizedTitle(context),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Container(
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
          ),
        ),
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
                  return Center(
                    child: Text(_getLocalizedEmptyMessage(context)),
                  );
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
                            label: _getLocalizedAllCategory(context),
                            selected: _selectedCategory ==
                                _getLocalizedAllCategory(context),
                            onSelected: (selected) => _updateCategory(
                                _getLocalizedAllCategory(context)),
                            style: ChipTheme.of(context).copyWith(
                              backgroundColor:
                                  const Color(0xFF2C3E50).withOpacity(0.05),
                              selectedColor: const Color(0xFF2C3E50),
                              labelStyle: TextStyle(
                                color: _selectedCategory ==
                                        _getLocalizedAllCategory(context)
                                    ? Colors.white
                                    : const Color(0xFF2C3E50),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          ...state.categoryTotals.keys.map(
                            (category) => ExpenseFilterChip(
                              label: _getLocalizedCategory(context, category),
                              selected: _selectedCategory == category,
                              onSelected: (selected) =>
                                  _updateCategory(category),
                              style: ChipTheme.of(context).copyWith(
                                backgroundColor:
                                    const Color(0xFF2C3E50).withOpacity(0.05),
                                selectedColor: const Color(0xFF2C3E50),
                                labelStyle: TextStyle(
                                  color: _selectedCategory == category
                                      ? Colors.white
                                      : const Color(0xFF2C3E50),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemCount: state.expenses.length,
                        itemBuilder: (context, index) {
                          final expense = state.expenses[index];
                          if (_selectedCategory !=
                                  _getLocalizedAllCategory(context) &&
                              expense.category != _selectedCategory) {
                            return const SizedBox.shrink();
                          }
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  const Color(0xFF2C3E50).withOpacity(0.1),
                              child: Icon(
                                _getCategoryIcon(expense.category),
                                color: const Color(0xFF2C3E50),
                                size: 20,
                              ),
                            ),
                            title: Text(expense.description),
                            subtitle: Text(
                              _getLocalizedDate(context, expense.date),
                            ),
                            trailing: AmountDisplay(
                              amount: expense.amount,
                              currency: expense.currency,
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
      case 'beauty':
        return Icons.face;
      case 'utilities':
        return Icons.receipt_long;
      case 'education':
        return Icons.school;
      case 'savings':
        return Icons.savings;
      case 'travel':
        return Icons.flight;
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

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Expense History',
      AppLanguage.korean: '지출 내역',
      AppLanguage.japanese: '支出履歴',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedEmptyMessage(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> messages = {
      AppLanguage.english: 'No expense history.',
      AppLanguage.korean: '지출 내역이 없습니다.',
      AppLanguage.japanese: '支履歴がありません。',
    };
    return messages[language] ?? messages[AppLanguage.korean]!;
  }

  String _getLocalizedAllCategory(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> categories = {
      AppLanguage.english: 'All',
      AppLanguage.korean: '전체',
      AppLanguage.japanese: '全て',
    };
    return categories[language] ?? categories[AppLanguage.korean]!;
  }

  String _getLocalizedCategory(BuildContext context, String category) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> categories = {
      'food': {
        AppLanguage.english: 'Food',
        AppLanguage.korean: '식비',
        AppLanguage.japanese: '食費',
      },
      'transport': {
        AppLanguage.english: 'Transport',
        AppLanguage.korean: '교통',
        AppLanguage.japanese: '交通',
      },
      'shopping': {
        AppLanguage.english: 'Shopping',
        AppLanguage.korean: '쇼핑',
        AppLanguage.japanese: '買物',
      },
      'entertainment': {
        AppLanguage.english: 'Entertainment',
        AppLanguage.korean: '여가',
        AppLanguage.japanese: '娯楽',
      },
      'health': {
        AppLanguage.english: 'Medical',
        AppLanguage.korean: '의료',
        AppLanguage.japanese: '医療',
      },
      'beauty': {
        AppLanguage.english: 'Beauty',
        AppLanguage.korean: '미용',
        AppLanguage.japanese: '美容',
      },
      'utilities': {
        AppLanguage.english: 'Utilities',
        AppLanguage.korean: '공과금',
        AppLanguage.japanese: '公共料金',
      },
      'education': {
        AppLanguage.english: 'Education',
        AppLanguage.korean: '교육',
        AppLanguage.japanese: '教育',
      },
      'savings': {
        AppLanguage.english: 'Savings',
        AppLanguage.korean: '저축',
        AppLanguage.japanese: '貯蓄',
      },
      'travel': {
        AppLanguage.english: 'Travel',
        AppLanguage.korean: '여행',
        AppLanguage.japanese: '旅行',
      },
    };
    return categories[category.toLowerCase()]?[language] ?? category;
  }

  String _getLocalizedDate(BuildContext context, DateTime date) {
    final language = context.read<AppLanguageBloc>().state.language;
    switch (language) {
      case AppLanguage.english:
        return DateFormat('MMM d').format(date);
      case AppLanguage.japanese:
        return DateFormat('M月 d日').format(date);
      case AppLanguage.korean:
      default:
        return DateFormat('M월 d일').format(date);
    }
  }
}
