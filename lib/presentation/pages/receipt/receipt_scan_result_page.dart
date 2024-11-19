import 'dart:io';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.file(File(imagePath)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '분석 결과',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('상점명', state.receipt.merchantName),
                  _buildInfoRow(
                      '날짜', state.receipt.date.toString().split(' ')[0]),
                  _buildInfoRow(
                    '총액',
                    NumberFormat.currency(
                      locale: 'ko_KR',
                      symbol: '₩',
                    ).format(state.receipt.totalAmount),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (state.receipt.items.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '구매 항목',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.receipt.items.length,
                      itemBuilder: (context, index) {
                        final item = state.receipt.items[index];
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text('수량: ${item.quantity}'),
                          trailing: Text(
                            NumberFormat.currency(
                              locale: 'ko_KR',
                              symbol: '₩',
                            ).format(item.totalPrice),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final authState = context.read<AuthBloc>().state;
              if (authState is Authenticated) {
                context.read<ReceiptBloc>().add(SaveReceipt(state.receipt));
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('저장하기'),
          ),
        ],
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
