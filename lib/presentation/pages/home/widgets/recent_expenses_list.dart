// lib/presentation/pages/home/widgets/recent_expenses_list.dart
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/presentation/bloc/expense/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../bloc/expense/expense_bloc.dart';
import '../../../../domain/entities/expense.dart';
import 'package:go_router/go_router.dart';

class RecentExpensesList extends StatelessWidget {
  const RecentExpensesList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is! ExpenseLoaded) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.expenses.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Text(
                _getLocalizedEmptyMessage(context),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        final recentExpenses = state.expenses.take(5).toList();

        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentExpenses.length,
              itemBuilder: (context, index) {
                return _ExpenseListTile(
                  expense: recentExpenses[index],
                  onTap: () =>
                      _showExpenseDetails(context, recentExpenses[index]),
                );
              },
            ),
            if (state.expenses.length > 5)
              TextButton(
                onPressed: () => context.go('/expenses'),
                child: Text(_getLocalizedViewAllButton(context)),
              ),
          ],
        );
      },
    );
  }

  String _getLocalizedEmptyMessage(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> messages = {
      AppLanguage.english: 'No expense history yet.',
      AppLanguage.korean: '아직 지출 내역이 없습니다.',
      AppLanguage.japanese: 'まだ支出履歴がありません。',
    };
    return messages[language] ?? messages[AppLanguage.korean]!;
  }

  String _getLocalizedViewAllButton(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> buttons = {
      AppLanguage.english: 'View All Expenses',
      AppLanguage.korean: '전체 지출 내역 보기',
      AppLanguage.japanese: '全ての支出履歴を見る',
    };
    return buttons[language] ?? buttons[AppLanguage.korean]!;
  }

  void _showExpenseDetails(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExpenseDetailsBottomSheet(expense: expense),
    );
  }
}

class _ExpenseListTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;

  const _ExpenseListTile({
    required this.expense,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // 카테고리 아이콘
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getCategoryColor(expense.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(expense.category),
                  color: _getCategoryColor(expense.category),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // 지출 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      DateFormat('M월 d일').format(expense.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // 금액
              Text(
                '${NumberFormat('#,###').format(expense.amount)}원',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // 영수증 아이콘 (있는 경우)
              if (expense.receiptId != null) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.receipt_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'shopping':
        return Colors.pink;
      case 'entertainment':
        return Colors.purple;
      case 'health':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_outlined;
      case 'transport':
        return Icons.directions_bus_outlined;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'entertainment':
        return Icons.movie_outlined;
      case 'health':
        return Icons.favorite_outline;
      default:
        return Icons.attach_money;
    }
  }
}

class _ExpenseDetailsBottomSheet extends StatelessWidget {
  final Expense expense;

  const _ExpenseDetailsBottomSheet({
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getLocalizedTitle(context),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          _DetailItem(
            title: _getLocalizedField(context, 'amount'),
            value: '${NumberFormat('#,###').format(expense.amount)}원',
          ),
          _DetailItem(
            title: _getLocalizedField(context, 'description'),
            value: expense.description,
          ),
          _DetailItem(
            title: _getLocalizedField(context, 'category'),
            value: expense.category,
          ),
          _DetailItem(
            title: _getLocalizedField(context, 'date'),
            value: DateFormat('yyyy년 M월 d일').format(expense.date),
          ),
          if (expense.isShared)
            _DetailItem(
              title: _getLocalizedField(context, 'shared'),
              value: _getLocalizedSharedText(
                  context, expense.sharedWith?.length ?? 0),
            ),
          if (expense.receiptId != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/receipts/${expense.receiptId}');
                },
                icon: const Icon(Icons.receipt_outlined),
                label: Text(_getLocalizedViewReceiptButton(context)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getLocalizedTitle(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> titles = {
      AppLanguage.english: 'Expense Details',
      AppLanguage.korean: '지출 상세',
      AppLanguage.japanese: '支出詳細',
    };
    return titles[language] ?? titles[AppLanguage.korean]!;
  }

  String _getLocalizedField(BuildContext context, String field) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> fields = {
      'amount': {
        AppLanguage.english: 'Amount',
        AppLanguage.korean: '금액',
        AppLanguage.japanese: '金額',
      },
      'description': {
        AppLanguage.english: 'Description',
        AppLanguage.korean: '내용',
        AppLanguage.japanese: '内容',
      },
      'category': {
        AppLanguage.english: 'Category',
        AppLanguage.korean: '카테고리',
        AppLanguage.japanese: 'カテゴリー',
      },
      'date': {
        AppLanguage.english: 'Date',
        AppLanguage.korean: '날짜',
        AppLanguage.japanese: '日付',
      },
      'shared': {
        AppLanguage.english: 'Shared',
        AppLanguage.korean: '공유',
        AppLanguage.japanese: '共有',
      },
    };
    return fields[field]![language] ?? fields[field]![AppLanguage.korean]!;
  }

  String _getLocalizedSharedText(BuildContext context, int sharedCount) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> sharedTexts = {
      AppLanguage.english: 'with',
      AppLanguage.korean: '과',
      AppLanguage.japanese: 'と',
    };
    return '${sharedCount}명과 ${sharedTexts[language]!} ${sharedCount}명';
  }

  String _getLocalizedViewReceiptButton(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> buttons = {
      AppLanguage.english: 'View Receipt',
      AppLanguage.korean: '영수증 보기',
      AppLanguage.japanese: 'レシートを見る',
    };
    return buttons[language] ?? buttons[AppLanguage.korean]!;
  }
}

class _DetailItem extends StatelessWidget {
  final String title;
  final String value;

  const _DetailItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
