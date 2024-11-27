// lib/presentation/pages/expense/widgets/expense_details_bottom_sheet.dart
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:finpal/presentation/bloc/expense/expense_bloc.dart';
import 'package:finpal/presentation/bloc/expense/expense_event.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_bloc.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_state.dart';
import 'package:finpal/presentation/pages/expense/widget/edit_expense_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/expense.dart';
import 'package:go_router/go_router.dart';

class ExpenseDetailsBottomSheet extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailsBottomSheet({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  fontSize: 20,
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
            title: _getLocalizedLabel(context, 'amount'),
            value: _getLocalizedAmount(context, expense.amount),
          ),
          _DetailItem(
            title: _getLocalizedLabel(context, 'description'),
            value: expense.description,
          ),
          _DetailItem(
            title: _getLocalizedLabel(context, 'category'),
            value: _getLocalizedCategory(context, expense.category),
          ),
          _DetailItem(
            title: _getLocalizedLabel(context, 'date'),
            value: _getLocalizedDate(context, expense.date),
          ),
          if (expense.isShared)
            _DetailItem(
              title: _getLocalizedLabel(context, 'shared'),
              value: _getLocalizedSharedText(
                  context, expense.sharedWith?.length ?? 0),
            ),
          if (expense.receiptId != null)
            BlocBuilder<ReceiptBloc, ReceiptState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/receipts/${expense.receiptId}');
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: Text(_getLocalizedLabel(context, 'view_receipt')),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditExpenseBottomSheet(context);
                    },
                    icon: const Icon(Icons.edit),
                    label: Text(_getLocalizedLabel(context, 'edit')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteConfirmDialog(context),
                    icon: const Icon(Icons.delete),
                    label: Text(_getLocalizedLabel(context, 'delete')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
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

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
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
      'view_receipt': {
        AppLanguage.english: 'View Receipt',
        AppLanguage.korean: '영수증 보기',
        AppLanguage.japanese: 'レシートを見る',
      },
      'edit': {
        AppLanguage.english: 'Edit',
        AppLanguage.korean: '수정',
        AppLanguage.japanese: '編集',
      },
      'delete': {
        AppLanguage.english: 'Delete',
        AppLanguage.korean: '삭제',
        AppLanguage.japanese: '削除',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
  }

  String _getLocalizedAmount(BuildContext context, double amount) {
    final currency = context.read<AppSettingsBloc>().state.currency;
    final formatter = NumberFormat('#,###');
    final formattedAmount = formatter.format(amount);

    final currencySymbols = {
      'KRW': '원',
      'JPY': '¥',
      'USD': '\$',
      'EUR': '€',
    };

    final symbol = currencySymbols[currency] ?? currencySymbols['KRW']!;

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

  String _getLocalizedDate(BuildContext context, DateTime date) {
    final language = context.read<AppLanguageBloc>().state.language;
    switch (language) {
      case AppLanguage.english:
        return DateFormat('MMM d, yyyy').format(date);
      case AppLanguage.japanese:
        return DateFormat('yyyy年 M月 d日').format(date);
      case AppLanguage.korean:
      default:
        return DateFormat('yyyy년 M월 d일').format(date);
    }
  }

  String _getLocalizedSharedText(BuildContext context, int count) {
    final language = context.read<AppLanguageBloc>().state.language;
    switch (language) {
      case AppLanguage.english:
        return 'Shared with $count people';
      case AppLanguage.japanese:
        return '$count人と共有中';
      case AppLanguage.korean:
      default:
        return '${count}명과 공유됨';
    }
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
      'others': {
        AppLanguage.english: 'Others',
        AppLanguage.korean: '기타',
        AppLanguage.japanese: 'その他',
      },
    };
    return categories[category.toLowerCase()]?[language] ?? category;
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getLocalizedLabel(context, 'delete_expense')),
        content: Text(_getLocalizedDeleteConfirmMessage(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getLocalizedLabel(context, 'cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/expenses');
              context.read<ExpenseBloc>()
                ..add(DeleteExpense(expense.id, expense.userId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(_getLocalizedDeleteSuccessMessage(context))),
              );
            },
            child: Text(
              _getLocalizedLabel(context, 'delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedDeleteConfirmMessage(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> messages = {
      AppLanguage.english:
          'Are you sure you want to delete this expense?\nDeleted expenses cannot be recovered.',
      AppLanguage.korean: '이 지출을 삭제하시겠습니까?\n삭제된 지출은 복구할 수 없습니다.',
      AppLanguage.japanese: 'この支出を削除しますか？\n削除された支出は復元できません。',
    };
    return messages[language] ?? messages[AppLanguage.korean]!;
  }

  String _getLocalizedDeleteSuccessMessage(BuildContext context) {
    final language = context.read<AppLanguageBloc>().state.language;
    const Map<AppLanguage, String> messages = {
      AppLanguage.english: 'Expense has been deleted.',
      AppLanguage.korean: '지출이 삭제되었습니다.',
      AppLanguage.japanese: '支出が削除されました。',
    };
    return messages[language] ?? messages[AppLanguage.korean]!;
  }

  void _showEditExpenseBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditExpenseBottomSheet(expense: expense),
    );
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
                color: Colors.grey[600],
                fontSize: 14,
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
