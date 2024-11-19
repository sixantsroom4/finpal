import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/receipt.dart';
import '../../../bloc/receipt/receipt_bloc.dart';
import '../../../bloc/receipt/receipt_event.dart';

class EditReceiptBottomSheet extends StatefulWidget {
  final Receipt receipt;

  const EditReceiptBottomSheet({
    super.key,
    required this.receipt,
  });

  @override
  State<EditReceiptBottomSheet> createState() => _EditReceiptBottomSheetState();
}

class _EditReceiptBottomSheetState extends State<EditReceiptBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _merchantNameController;
  late final TextEditingController _totalAmountController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _merchantNameController =
        TextEditingController(text: widget.receipt.merchantName);
    _totalAmountController =
        TextEditingController(text: widget.receipt.totalAmount.toString());
    _selectedDate = widget.receipt.date;
  }

  @override
  void dispose() {
    _merchantNameController.dispose();
    _totalAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '영수증 수정',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _merchantNameController,
              decoration: const InputDecoration(
                labelText: '상점명',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '상점명을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalAmountController,
              decoration: const InputDecoration(
                labelText: '총액',
                border: OutlineInputBorder(),
                suffix: Text('원'),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '총액을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('날짜'),
              subtitle: Text(_selectedDate.toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('저장'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedReceipt = Receipt(
        id: widget.receipt.id,
        imageUrl: widget.receipt.imageUrl,
        date: _selectedDate,
        merchantName: _merchantNameController.text.trim(),
        totalAmount: double.parse(_totalAmountController.text),
        items: widget.receipt.items,
        userId: widget.receipt.userId,
        expenseId: widget.receipt.expenseId,
      );

      context.read<ReceiptBloc>().add(UpdateReceipt(updatedReceipt));
      Navigator.pop(context);
    }
  }
}
