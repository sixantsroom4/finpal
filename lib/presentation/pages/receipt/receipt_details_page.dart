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

class ReceiptDetailsPage extends StatelessWidget {
  final String receiptId;
  final _numberFormat = NumberFormat('#,###');

  ReceiptDetailsPage({
    Key? key,
    required this.receiptId,
  }) : super(key: key);

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

  String _getLocalizedAmount(BuildContext context, double amount) {
    final currency = context.read<AppSettingsBloc>().state.currency;
    final formattedAmount = _numberFormat.format(amount);

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReceiptBloc, ReceiptState>(
      builder: (context, state) {
        if (state is ReceiptLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ReceiptError) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/expenses'),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getLocalizedLabel(context, 'receipt_not_found'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getLocalizedLabel(context, 'receipt_not_found_desc'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/expenses'),
                    child:
                        Text(_getLocalizedLabel(context, 'back_to_expenses')),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! ReceiptLoaded) {
          context.read<ReceiptBloc>().add(LoadReceiptById(receiptId));
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final receipt = state.receipts.firstWhere(
          (r) => r.id == receiptId,
          orElse: () {
            context.read<ReceiptBloc>().add(LoadReceiptById(receiptId));
            return ReceiptModel(
              id: receiptId,
              userId: '',
              merchantName: _getLocalizedLabel(context, 'loading'),
              date: DateTime.now(),
              totalAmount: 0,
              currency: 'USD',
              imageUrl: '',
              items: [],
            );
          },
        );

        if (receipt.merchantName == _getLocalizedLabel(context, 'loading')) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(receipt.merchantName),
            actions: [
              PopupMenuButton<String>(
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
                        const Icon(Icons.edit),
                        const SizedBox(width: 8),
                        Text(_getLocalizedLabel(context, 'edit')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          _getLocalizedLabel(context, 'delete'),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 영수증 이미지
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: receipt.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                // 영수증 정보
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLocalizedLabel(context, 'purchase_info'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(height: 32),
                        _buildInfoRow(_getLocalizedLabel(context, 'store'),
                            receipt.merchantName),
                        _buildInfoRow(_getLocalizedLabel(context, 'date'),
                            _getLocalizedDate(context, receipt.date)),
                        _buildInfoRow(_getLocalizedLabel(context, 'total'),
                            _getLocalizedAmount(context, receipt.totalAmount)),
                        if (receipt.items.isNotEmpty) ...[
                          const Divider(height: 32),
                          Text(
                            _getLocalizedLabel(context, 'items'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
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
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, ReceiptItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(item.name)),
          Expanded(
            child: Text(
              _getLocalizedAmount(context, item.price),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text('x${item.quantity}', textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text(
              _getLocalizedAmount(context, item.totalPrice),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, Receipt receipt) {
    if (receipt.expenseId != null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () => _createExpense(context, receipt),
          icon: const Icon(Icons.add_card),
          label: Text(_getLocalizedLabel(context, 'create_expense')),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
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
        title: Text(_getLocalizedLabel(context, 'delete_receipt')),
        content: Text(_getLocalizedLabel(context, 'delete_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getLocalizedLabel(context, 'cancel')),
          ),
          TextButton(
            onPressed: () {
              // ReceiptBloc에 삭제 이벤트 전달
              context.read<ReceiptBloc>()
                ..add(DeleteReceipt(receipt.id))
                ..add(LoadReceipts(receipt.userId));

              // ExpenseBloc에도 새로고침 이벤트 전달
              if (receipt.expenseId != null) {
                context.read<ExpenseBloc>().add(LoadExpenses(receipt.userId));
              }

              Navigator.pop(context); // 다이얼로그 닫기
              context.go('/receipts'); // 목록 페이지로 이동
            },
            child: Text(
              _getLocalizedLabel(context, 'delete'),
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
