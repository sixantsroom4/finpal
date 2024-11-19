// lib/presentation/pages/expense/widgets/expense_details_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/expense.dart';

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
              const Text(
                '지출 상세',
                style: TextStyle(
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
            title: '금액',
            value: '${NumberFormat('#,###').format(expense.amount)}원',
          ),
          _DetailItem(
            title: '내용',
            value: expense.description,
          ),
          _DetailItem(
            title: '카테고리',
            value: expense.category,
          ),
          _DetailItem(
            title: '날짜',
            value: DateFormat('yyyy년 M월 d일').format(expense.date),
          ),
          if (expense.isShared)
            _DetailItem(
              title: '공유',
              value: '${expense.sharedWith?.length ?? 0}명과 공유됨',
            ),
          if (expense.receiptUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: 영수증 상세 보기 구현
                },
                icon: const Icon(Icons.receipt_long),
                label: const Text('영수증 보기'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: 지출 수정 구현
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('수정'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: 지출 삭제 구현
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('삭제'),
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
