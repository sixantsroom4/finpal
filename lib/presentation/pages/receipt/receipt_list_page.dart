import 'dart:async';

import 'package:finpal/presentation/bloc/auth/auth_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_bloc.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_event.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_state.dart';
import 'package:finpal/presentation/pages/receipt/receipt_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReceiptListPage extends StatefulWidget {
  @override
  State<ReceiptListPage> createState() => _ReceiptListPageState();
}

class _ReceiptListPageState extends State<ReceiptListPage> {
  late StreamSubscription<void> _receiptSubscription;

  @override
  void initState() {
    super.initState();
    final receiptBloc = context.read<ReceiptBloc>();
    _receiptSubscription = receiptBloc.receiptStream.listen((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        context.read<ReceiptBloc>().add(LoadReceipts(authState.user.id));
      }
    });
  }

  @override
  void dispose() {
    _receiptSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReceiptBloc, ReceiptState>(
      builder: (context, state) {
        if (state is ReceiptScanInProgress) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('영수증 분석 중...'),
              ],
            ),
          );
        } else if (state is ReceiptAnalysisSuccess) {
          return SnackBar(
            content: Text('영수증 분석이 완료되었습니다.'),
            backgroundColor: Colors.green,
          );
        } else if (state is ReceiptError) {
          return SnackBar(
            content: Text(state.message ?? '영수증 처리 중 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          );
        }

        if (state is ReceiptLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ReceiptError) {
          return Center(child: Text(state.message));
        }

        if (state is ReceiptLoaded) {
          if (state.receipts.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            itemCount: state.receipts.length,
            itemBuilder: (context, index) {
              final receipt = state.receipts[index];
              return ReceiptListItem(receipt: receipt);
            },
          );
        }

        return _buildEmptyState(context);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '저장된 영수증이 없습니다',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text(
            '영수증을 스캔하여 자동으로 지출을 기록해보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}
