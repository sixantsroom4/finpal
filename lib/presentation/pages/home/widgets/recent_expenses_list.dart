// lib/presentation/pages/home/widgets/recent_expenses_list.dart
import 'package:finpal/presentation/bloc/expense/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../bloc/expense/expense_bloc.dart';
import '../../../../domain/entities/expense.dart';
import 'package:go_router/go_router.dart';

class RecentExpensesList extends StatelessWidget {
  const RecentExpensesList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is! ExpenseLoaded) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.expenses.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text(
                '아직 지출 내역이 없습니다.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        // 최근 5개의 지출만 표시
        final recentExpenses = state.expenses.take(5).toList();

        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentExpenses.length,
              itemBuilder: (context, index) {
                return _ExpenseListTile(
                  expense: recentExpenses[index],
                  onTap: () =>
                      _showExpenseDetails(context, recentExpenses[index]),
                );
              },
            ),
            // 더보기 버튼
            if (state.expenses.length > 5)
              TextButton(
                onPressed: () {
                  // 지출 내역 페이지로 이동
                  context.go('/expenses');
                },
                child: const Text('전체 지출 내역 보기'),
              ),
          ],
        );
      },
    );
  }

  void _showExpenseDetails(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExpenseDetailsBottomSheet(expense: expense),
    );
  }
}

class _ExpenseListTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;

  const _ExpenseListTile({
    required this.expense,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // 카테고리 아이콘
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getCategoryColor(expense.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(expense.category),
                  color: _getCategoryColor(expense.category),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // 지출 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      DateFormat('M월 d일').format(expense.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // 금액
              Text(
                '${NumberFormat('#,###').format(expense.amount)}원',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // 영수증 아이콘 (있는 경우)
              if (expense.receiptId != null) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.receipt_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'shopping':
        return Colors.pink;
      case 'entertainment':
        return Colors.purple;
      case 'health':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_outlined;
      case 'transport':
        return Icons.directions_bus_outlined;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'entertainment':
        return Icons.movie_outlined;
      case 'health':
        return Icons.favorite_outline;
      default:
        return Icons.attach_money;
    }
  }
}

class _ExpenseDetailsBottomSheet extends StatelessWidget {
  final Expense expense;

  const _ExpenseDetailsBottomSheet({
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '지출 상세',
                style: TextStyle(
                  fontSize: 18,
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
          // 상세 정보
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
          // 영수증이 있는 경우 보기 버튼
          if (expense.receiptId != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/receipts/${expense.receiptId}');
                },
                icon: const Icon(Icons.receipt_outlined),
                label: const Text('영수증 보기'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                ),
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
                fontSize: 14,
                color: Colors.grey[600],
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
