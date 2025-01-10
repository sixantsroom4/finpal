// lib/presentation/pages/expense/expense_page.dart
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/core/utils/expense_category_constants.dart';
import 'package:finpal/core/utils/subscription_category_constants.dart';
import 'package:finpal/domain/entities/expense.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/expense/expense_event.dart';
import 'package:finpal/presentation/bloc/expense/expense_state.dart';
import 'package:finpal/presentation/bloc/subscription/subscription_event.dart';
import 'package:finpal/presentation/bloc/subscription/subscription_state.dart';
import 'package:finpal/presentation/pages/expense/widget/add_expense_fab.dart';
import 'package:finpal/presentation/pages/expense/widget/expense_details_bottom_sheet.dart';
import 'package:finpal/presentation/pages/expense/widget/expense_filter_chip.dart';
import 'package:finpal/presentation/pages/expense/widget/monthly_expense_card.dart';
import 'package:finpal/presentation/pages/subscription/widgets/subscription_details_bottom_sheet.dart';
import 'package:finpal/presentation/widgets/amount_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/app_language/app_language_bloc.dart';
import 'widgets/empty_expense_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/utils/subscription_category_constants.dart';
import '../../../core/utils/expense_category_constants.dart';
import '../../bloc/subscription/subscription_bloc.dart';

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
                if (state is ExpenseInitial ||
                    (state is ExpenseLoaded && state.expenses.isEmpty)) {
                  return const EmptyExpenseView();
                }

                if (state is ExpenseLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ExpenseError) {
                  return Center(child: Text(state.message));
                }

                if (state is ExpenseLoaded) {
                  final filteredExpenses = state.expenses.where((expense) {
                    final appLanguage =
                        context.read<AppLanguageBloc>().state.language;
                    return _selectedCategory ==
                            _getLocalizedAllCategory(context) ||
                        (expense.isSubscription == true &&
                            SubscriptionCategoryConstants.getLocalizedCategory(
                                    context, expense.category) ==
                                _selectedCategory) ||
                        (expense.isSubscription != true &&
                            ExpenseCategoryConstants.getLocalizedCategory(
                                    expense.category, appLanguage) ==
                                _selectedCategory);
                  }).toList();

                  if (filteredExpenses.isEmpty) {
                    return const EmptyExpenseView();
                  }

                  // 현재 지출 내역에 있는 카테고리 목록 생성
                  final Set<String> availableCategories = {};
                  availableCategories.add(_getLocalizedAllCategory(context));
                  for (var expense in state.expenses) {
                    if (expense.isSubscription == true) {
                      availableCategories.add(
                        SubscriptionCategoryConstants.getLocalizedCategory(
                            context, expense.category),
                      );
                    } else {
                      availableCategories.add(
                        ExpenseCategoryConstants.getLocalizedCategory(
                            expense.category,
                            context.read<AppLanguageBloc>().state.language),
                      );
                    }
                  }

                  return Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            // "전체" 카테고리 필터 칩
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
                            // 사용 가능한 구독 카테고리 필터 칩
                            ...availableCategories
                                .where((category) =>
                                    category !=
                                    _getLocalizedAllCategory(context))
                                .map((category) {
                              return ExpenseFilterChip(
                                label: category,
                                selected: _selectedCategory == category,
                                onSelected: (selected) {
                                  if (selected) {
                                    _updateCategory(category);
                                  }
                                },
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
                              );
                            }),
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
                          itemCount: filteredExpenses.length,
                          itemBuilder: (context, index) {
                            final expense = filteredExpenses[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Icon(
                                  expense.isSubscription == true
                                      ? SubscriptionCategoryConstants
                                                  .categoryIcons[
                                              expense.category.toUpperCase()] ??
                                          Icons.category_outlined
                                      : ExpenseCategoryConstants.categoryIcons[
                                              expense.category] ??
                                          Icons.category_outlined,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                '${expense.category} - '
                                '${expense.isSubscription == true ? SubscriptionCategoryConstants.getLocalizedCategory(context, expense.category) : ExpenseCategoryConstants.getLocalizedCategory(expense.category, context.read<AppLanguageBloc>().state.language)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(expense.description),
                              trailing: AmountDisplay(
                                amount: expense.amount,
                                currency: expense.currency,
                              ),
                              onTap: () =>
                                  _showExpenseDetails(context, expense),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AddExpenseFab(),
    );
  }

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Expenses',
      AppLanguage.korean: '지출',
      AppLanguage.japanese: '支出',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedAllCategory(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> categories = {
      AppLanguage.english: 'All',
      AppLanguage.korean: '전체',
      AppLanguage.japanese: 'すべて',
    };
    return categories[language] ?? categories[AppLanguage.korean]!;
  }

  void _updateCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _showExpenseDetails(BuildContext context, Expense expense) {
    if (expense.isSubscription && expense.subscriptionId != null) {
      // 구독 상세 정보 조회 및 표시
      context
          .read<SubscriptionBloc>()
          .add(LoadSubscriptionById(expense.subscriptionId!));

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, state) {
            if (state is SubscriptionLoaded) {
              return SubscriptionDetailsBottomSheet(
                subscription: state.subscriptions.first,
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    } else {
      // 일반 지출 상세 표시
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => ExpenseDetailsBottomSheet(
          expense: expense,
        ),
      );
    }
  }
}
