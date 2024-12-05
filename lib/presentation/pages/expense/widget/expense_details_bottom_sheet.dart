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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 드래그 핸들
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 금액 표시
          Center(
            child: Text(
              _getLocalizedAmount(context, expense.amount),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 상세 정보 리스트
          _buildDetailItem(
            context,
            Icons.description_outlined,
            '설명',
            expense.description,
          ),
          _buildDetailItem(
            context,
            Icons.category_outlined,
            '카테고리',
            _getLocalizedCategory(context, expense.category),
          ),
          _buildDetailItem(
            context,
            Icons.calendar_today_outlined,
            '날짜',
            _getLocalizedDate(context, expense.date),
          ),

          const SizedBox(height: 24),

          // 영수증 버튼 (영수증이 있는 경우에만 표시)
          if (expense.receiptId != null) ...[
            OutlinedButton.icon(
              onPressed: () => context.push('/receipts/${expense.receiptId}'),
              icon: const Icon(
                Icons.receipt_outlined,
                color: Color(0xFF2C3E50),
              ),
              label: Text(
                _getLocalizedLabel(context, 'view_receipt'),
                style: const TextStyle(
                  color: Color(0xFF2C3E50),
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 0),
                side: const BorderSide(color: Color(0xFF2C3E50)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 수정/삭제 버튼 Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _editExpense(context),
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.blue,
                  ),
                  label: Text(
                    _getLocalizedLabel(context, 'edit'),
                    style: const TextStyle(color: Colors.blue),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deleteExpense(context),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  label: Text(
                    _getLocalizedLabel(context, 'delete'),
                    style: const TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.red),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2C3E50),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
      AppLanguage.korean: '이 지출을 삭하시겠습니까?\n삭제된 지출은 복구할 수 없습니다.',
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

  void _editExpense(BuildContext context) {
    Navigator.pop(context);
    _showEditExpenseBottomSheet(context);
  }

  void _deleteExpense(BuildContext context) {
    Navigator.pop(context);
    _showDeleteConfirmDialog(context);
  }

  String _getLocalizedText(BuildContext context, String key) {
    return _getLocalizedLabel(context, key);
  }
}
