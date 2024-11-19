import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/entities/receipt.dart';
import '../../../../domain/entities/expense.dart';
import '../../../bloc/expense/expense_bloc.dart';
import '../../../bloc/expense/expense_event.dart';
import '../../../bloc/receipt/receipt_bloc.dart';
import '../../../bloc/receipt/receipt_event.dart';
import '../../../../core/utils/constants.dart';

class CreateExpenseFromReceipt extends StatefulWidget {
  final Receipt receipt;

  const CreateExpenseFromReceipt({
    super.key,
    required this.receipt,
  });

  @override
  State<CreateExpenseFromReceipt> createState() =>
      _CreateExpenseFromReceiptState();
}

class _CreateExpenseFromReceiptState extends State<CreateExpenseFromReceipt> {
  String _selectedCategory = CategoryConstants.food;
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.receipt.merchantName;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '지출 내역 생성',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '내용',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: '카테고리',
              border: OutlineInputBorder(),
            ),
            items: CategoryConstants.getAll().map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value ?? CategoryConstants.food;
              });
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _createExpense,
                  child: const Text('생성'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _createExpense() {
    final expenseId = const Uuid().v4();

    final expense = Expense.create(
      amount: widget.receipt.totalAmount,
      description: _descriptionController.text,
      category: _selectedCategory,
      userId: widget.receipt.userId,
      receiptUrl: widget.receipt.imageUrl,
      receiptId: widget.receipt.id,
    );

    context.read<ExpenseBloc>().add(AddExpense(expense));

    // 영수증 업데이트 이벤트 발생 (expenseId 연결)
    context.read<ReceiptBloc>().add(UpdateReceipt(
          widget.receipt.copyWith(expenseId: expenseId),
        ));

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('지출 내역이 생성되었습니다.')),
    );
  }
}
