// lib/presentation/pages/receipt/receipt_details_page.dart
import 'package:finpal/data/models/receipt_model.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_bloc.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_event.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_state.dart';
import 'package:finpal/presentation/pages/receipt/widgets/create_expense_from_receipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/receipt.dart';
import 'package:go_router/go_router.dart';
import 'widgets/edit_receipt_bottom_sheet.dart';
import 'package:finpal/presentation/bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:finpal/presentation/bloc/expense/expense_bloc.dart';
import 'package:finpal/presentation/bloc/expense/expense_event.dart';
import 'package:finpal/presentation/bloc/expense/expense_state.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'widgets/edit_receipt_info_bottom_sheet.dart';
import 'package:finpal/core/utils/currency_utils.dart';
import 'package:collection/collection.dart';

class ReceiptDetailsPage extends StatelessWidget {
  final String receiptId;
  final _numberFormat = NumberFormat('#,###');

  ReceiptDetailsPage({
    super.key,
    required this.receiptId,
  });

  String _getLocalizedLabel(BuildContext context, String key) {
    final language = context.read<AppLanguageBloc>().state.language;
    final Map<String, Map<AppLanguage, String>> labels = {
      'receipt_not_found': {
        AppLanguage.english: 'Receipt Not Found',
        AppLanguage.korean: '영수증을 찾을 수 없습니다',
        AppLanguage.japanese: 'レシートが見つかりません',
      },
      'receipt_not_found_desc': {
        AppLanguage.english: 'The receipt has been deleted or does not exist',
        AppLanguage.korean: '해당 영수증이 삭제되었거나 존재하지 않습니다',
        AppLanguage.japanese: 'レシートが削除されたか存在しません',
      },
      'back_to_expenses': {
        AppLanguage.english: 'Back to Expenses',
        AppLanguage.korean: '지출 목록으로 돌아가기',
        AppLanguage.japanese: '支出一覧に戻る',
      },
      'loading': {
        AppLanguage.english: 'Loading...',
        AppLanguage.korean: '로딩 중...',
        AppLanguage.japanese: '読み込み中...',
      },
      'purchase_info': {
        AppLanguage.english: 'Purchase Information',
        AppLanguage.korean: '구매 정보',
        AppLanguage.japanese: '購入情報',
      },
      'store': {
        AppLanguage.english: 'Store',
        AppLanguage.korean: '상점',
        AppLanguage.japanese: '店舗',
      },
      'date': {
        AppLanguage.english: 'Date',
        AppLanguage.korean: '날짜',
        AppLanguage.japanese: '日付',
      },
      'total': {
        AppLanguage.english: 'Total',
        AppLanguage.korean: '총액',
        AppLanguage.japanese: '合計',
      },
      'items': {
        AppLanguage.english: 'Items',
        AppLanguage.korean: '구매 항목',
        AppLanguage.japanese: '購入項目',
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
      'create_expense': {
        AppLanguage.english: 'Create Expense',
        AppLanguage.korean: '지출 내역 생성',
        AppLanguage.japanese: '支出を作成',
      },
      'delete_receipt': {
        AppLanguage.english: 'Delete Receipt',
        AppLanguage.korean: '영수증 삭제',
        AppLanguage.japanese: 'レシートを削除',
      },
      'delete_confirm': {
        AppLanguage.english:
            'Are you sure you want to delete this receipt?\nDeleted receipts cannot be recovered.',
        AppLanguage.korean: '이 영수증을 삭제하시겠습니까?\n삭제된 영수증은 복구할 수 없습니다.',
        AppLanguage.japanese: 'このレシートを削除してもよろしいですか？\n削除されたレシートは復元できません。',
      },
      'cancel': {
        AppLanguage.english: 'Cancel',
        AppLanguage.korean: '취소',
        AppLanguage.japanese: 'キャンセル',
      },
      'view_expense': {
        AppLanguage.english: 'View Expense',
        AppLanguage.korean: '지출 내역 보기',
        AppLanguage.japanese: '支出を確認',
      },
    };
    return labels[key]?[language] ?? labels[key]?[AppLanguage.korean] ?? key;
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

  String _getLocalizedAmount(
      BuildContext context, double amount, Receipt receipt) {
    final currency = receipt.currency;
    final formatter = NumberFormat('#,###');
    final formattedAmount = formatter.format(amount);

    final currencySymbols = {
      'KRW': '원',
      'JPY': '¥',
      'USD': '\$',
      'EUR': '€',
    };

    final symbol = currencySymbols[currency] ?? currencySymbols['KRW']!;

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReceiptBloc, ReceiptState>(
      listener: (context, state) {
        if (state is ReceiptOperationSuccess) {
          // 삭제 성공 시 스낵바 표시 및 페이지 이동
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.go('/receipts');
        }
      },
      child: BlocBuilder<ReceiptBloc, ReceiptState>(
        builder: (context, state) {
          if (state is ReceiptLoading) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ReceiptError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text(state.message)),
            );
          }

          // receipt를 찾지 못한 경우를 별도로 처리
          final receipt = state.receipts.firstWhereOrNull(
            (r) => r.id == receiptId,
          );

          if (receipt == null) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_getLocalizedLabel(context, 'receipt_not_found')),
                    const SizedBox(height: 8),
                    Text(
                      _getLocalizedLabel(context, 'receipt_not_found_desc'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/receipts'),
                      child:
                          Text(_getLocalizedLabel(context, 'back_to_expenses')),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: const Color(0xFF2C3E50),
              elevation: 0,
              title: Text(
                receipt.merchantName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditReceipt(context, receipt);
                        break;
                      case 'delete':
                        _showDeleteConfirmDialog(context, receipt);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit,
                            color: Color(0xFF2C3E50),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getLocalizedLabel(context, 'edit'),
                            style: const TextStyle(
                              color: Color(0xFF2C3E50),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getLocalizedLabel(context, 'delete'),
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 영수증 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: receipt.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 영수증 정보
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: const Color(0xFF2C3E50).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getLocalizedLabel(context, 'purchase_info'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildInfoRow(
                            context,
                            _getLocalizedLabel(context, 'store'),
                            receipt.merchantName,
                          ),
                          _buildInfoRow(
                            context,
                            _getLocalizedLabel(context, 'date'),
                            _getLocalizedDate(context, receipt.date),
                          ),
                          _buildInfoRow(
                            context,
                            _getLocalizedLabel(context, 'total'),
                            '${CurrencyUtils.getCurrencySymbol(receipt.currency)} ${CurrencyUtils.formatAmount(receipt.totalAmount, receipt.currency)}',
                          ),
                          if (receipt.items.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text(
                              _getLocalizedLabel(context, 'items'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...receipt.items
                                .map((item) => _buildItemRow(context, item)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomButton(context, receipt),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF2C3E50).withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, ReceiptItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF2C3E50).withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${CurrencyUtils.getCurrencySymbol(item.currency)} ${CurrencyUtils.formatAmount(item.price, item.currency)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              'x${item.quantity}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${CurrencyUtils.getCurrencySymbol(item.currency)} ${CurrencyUtils.formatAmount(item.totalPrice, item.currency)}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, Receipt receipt) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: receipt.expenseId != null
            ? TextButton(
                onPressed: () => context.go('/expenses/${receipt.expenseId}'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2C3E50),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(
                    color: Color(0xFF2C3E50),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  _getLocalizedLabel(context, 'view_expense'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : TextButton(
                onPressed: () => _createExpense(context, receipt),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF2C3E50),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  _getLocalizedLabel(context, 'create_expense'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
    );
  }

  void _createExpense(BuildContext context, Receipt receipt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CreateExpenseFromReceipt(receipt: receipt),
    );
  }

  void _showEditReceipt(BuildContext context, Receipt receipt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditReceiptInfoBottomSheet(receipt: receipt),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Receipt receipt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          _getLocalizedLabel(context, 'delete_receipt'),
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          _getLocalizedLabel(context, 'delete_confirm'),
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _getLocalizedLabel(context, 'cancel'),
              style: const TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ReceiptBloc>().add(
                    DeleteReceipt(receipt.id, receipt.userId),
                  );
              if (receipt.expenseId != null) {
                context.read<ExpenseBloc>().add(LoadExpenses(receipt.userId));
              }
            },
            child: Text(
              _getLocalizedLabel(context, 'delete'),
              style: const TextStyle(
                color: Colors.red,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
