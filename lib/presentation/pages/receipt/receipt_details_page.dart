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

class ReceiptDetailsPage extends StatelessWidget {
  final String receiptId;
  final _numberFormat = NumberFormat('#,###');

  ReceiptDetailsPage({
    Key? key,
    required this.receiptId,
  }) : super(key: key);

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
                    '영수증을 찾을 수 없습니다',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '해당 영수증이 삭제되었거나 존재하지 않습니다',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/expenses'),
                    child: const Text('지출 목록으로 돌아가기'),
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
              merchantName: '로딩 중...',
              date: DateTime.now(),
              totalAmount: 0,
              imageUrl: '',
              items: [],
            );
          },
        );

        if (receipt.merchantName == '로딩 중...') {
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
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('수정'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('삭제', style: TextStyle(color: Colors.red)),
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
                          '구매 정보',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(height: 32),
                        _buildInfoRow('상점', receipt.merchantName),
                        _buildInfoRow('날짜',
                            DateFormat('yyyy년 M월 d일').format(receipt.date)),
                        _buildInfoRow('총액',
                            '${_numberFormat.format(receipt.totalAmount)}원'),
                        if (receipt.items.isNotEmpty) ...[
                          const Divider(height: 32),
                          Text(
                            '구매 항목',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          ...receipt.items.map((item) => _buildItemRow(item)),
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

  Widget _buildItemRow(ReceiptItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(item.name)),
          Expanded(
            child: Text(
              '${_numberFormat.format(item.price)}원',
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
              '${_numberFormat.format(item.totalPrice)}원',
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
          label: const Text('지출 내역 생성'),
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
      builder: (context) => EditReceiptBottomSheet(receipt: receipt),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Receipt receipt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('영수증 삭제'),
        content: const Text('이 영수증을 삭제하시겠습니까?\n삭제된 영수증은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
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
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
