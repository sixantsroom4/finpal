// lib/presentation/pages/receipt/receipt_details_page.dart
import 'package:finpal/presentation/bloc/receipt/receipt_bloc.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_event.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/receipt.dart';
import 'package:go_router/go_router.dart';
import 'widgets/edit_receipt_bottom_sheet.dart';
import 'package:finpal/presentation/bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';

class ReceiptDetailsPage extends StatelessWidget {
  final Receipt receipt;
  final numberFormat = NumberFormat('#,###');

  ReceiptDetailsPage({
    super.key,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReceiptBloc, ReceiptState>(
      listener: (context, state) {
        if (state is ReceiptOperationSuccess &&
            state.message == '영수증이 삭제되었습니다.') {
          final authState = context.read<AuthBloc>().state;
          if (authState is Authenticated) {
            context.read<ReceiptBloc>().add(LoadReceipts(authState.user.id));
          }
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('영수증 상세'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) =>
                      EditReceiptBottomSheet(receipt: receipt),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteReceipt(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 영수증 이미지
              AspectRatio(
                aspectRatio: 2 / 3,
                child: Image.network(
                  receipt.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                    );
                  },
                ),
              ),

              // 기본 정보
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          receipt.merchantName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          DateFormat('yyyy/MM/dd').format(receipt.date),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 품목 목록
                    const Text(
                      '구매 내역',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...receipt.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(item.name),
                              ),
                              Expanded(
                                child: Text(
                                  '${numberFormat.format(item.price)}원',
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 40,
                                child: Text(
                                  'x${item.quantity}',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${numberFormat.format(item.totalPrice)}원',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        )),

                    const Divider(height: 32),

                    // 총액
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '총액',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${numberFormat.format(receipt.totalAmount)}원',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: receipt.expenseId != null
                  ? () => _showExpenseDetails(context)
                  : () => _createExpense(context),
              icon: Icon(
                receipt.expenseId != null ? Icons.receipt_long : Icons.add_card,
              ),
              label: Text(
                receipt.expenseId != null ? '연결된 지출 보기' : '지출 내역 생성',
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _deleteReceipt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('영수증 삭제'),
        content: const Text('이 영수증을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              context.read<ReceiptBloc>().add(DeleteReceipt(receipt.id));
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

  void _showExpenseDetails(BuildContext context) {
    // TODO: 연결된 지출 상세 페이지로 이동
  }

  void _createExpense(BuildContext context) {
    // TODO: 영수증 기반으로 새 지출 생성
  }
}
