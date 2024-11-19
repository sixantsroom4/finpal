import 'dart:io';
import 'package:finpal/presentation/pages/receipt/widgets/create_expense_from_receipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/receipt/receipt_bloc.dart';
import '../../bloc/receipt/receipt_event.dart';
import '../../bloc/receipt/receipt_state.dart';
import 'receipt_page.dart';
import 'package:intl/intl.dart';

class ReceiptScanResultPage extends StatelessWidget {
  final String imagePath;

  const ReceiptScanResultPage({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('영수증 분석 결과'),
      ),
      body: BlocConsumer<ReceiptBloc, ReceiptState>(
        listener: (context, state) {
          if (state is ReceiptOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            if (state.message == '영수증이 저장되었습니다.') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReceiptPage(),
                ),
              );
            }
          }
          if (state is ReceiptError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ReceiptScanInProgress) {
            return _buildLoadingState();
          }

          if (state is ReceiptScanSuccess) {
            return _buildResultState(context, state);
          }

          return const Center(
            child: Text('영수증 분석 중 오류가 발생했습니다.'),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          const Text(
            'AI가 영수증을 분석하고 있습니다',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            '잠시만 기다려주세요...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultState(BuildContext context, ReceiptScanSuccess state) {
    final receipt = state.receipt;
    final formatter = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showFullScreenImage(context, imagePath),
            child: Hero(
              tag: 'receipt_image',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(imagePath)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(Icons.store,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              receipt.merchantName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              DateFormat('yyyy년 M월 d일').format(receipt.date),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  if (receipt.items.isNotEmpty) ...[
                    Text(
                      '구매 항목',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...receipt.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(item.name),
                              ),
                              Text(
                                  '${formatter.format(item.price)} x ${item.quantity}'),
                              const SizedBox(width: 8),
                              Text(
                                formatter.format(item.totalPrice),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )),
                    const Divider(height: 32),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '총액',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        formatter.format(receipt.totalAmount),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (receipt.expenseId == null)
                    ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => CreateExpenseFromReceipt(
                            receipt: receipt,
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_card),
                      label: const Text('지출 내역 생성'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Hero(
                  tag: 'receipt_image',
                  child: Image.file(File(imagePath)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
