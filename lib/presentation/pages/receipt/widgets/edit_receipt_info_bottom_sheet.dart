import 'package:finpal/domain/entities/receipt.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_bloc.dart';
import 'package:finpal/presentation/bloc/receipt/receipt_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class EditReceiptInfoBottomSheet extends StatefulWidget {
  final Receipt receipt;

  const EditReceiptInfoBottomSheet({
    super.key,
    required this.receipt,
  });

  @override
  State<EditReceiptInfoBottomSheet> createState() =>
      _EditReceiptInfoBottomSheetState();
}

class _EditReceiptInfoBottomSheetState
    extends State<EditReceiptInfoBottomSheet> {
  late TextEditingController _merchantNameController;
  late TextEditingController _totalAmountController;
  late List<ReceiptItem> _items;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _merchantNameController =
        TextEditingController(text: widget.receipt.merchantName);
    _totalAmountController = TextEditingController(
      text: NumberFormat('#,###').format(widget.receipt.totalAmount),
    );
    _items = List.from(widget.receipt.items);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                '영수증 정보 수정',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    TextFormField(
                      controller: _merchantNameController,
                      decoration: const InputDecoration(
                        labelText: '가게명',
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? '가게명을 입력해주세요' : null,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '구매 항목',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: item.name,
                                  decoration: const InputDecoration(
                                    labelText: '품목명',
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _items[index] =
                                          item.copyWith(name: value);
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: item.price.toString(),
                                  decoration: const InputDecoration(
                                    labelText: '단가',
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _items[index] = item.copyWith(
                                        price: double.tryParse(value) ?? 0,
                                      );
                                    });
                                    _updateTotalAmount();
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 60,
                                child: TextFormField(
                                  initialValue: item.quantity.toString(),
                                  decoration: const InputDecoration(
                                    labelText: '수량',
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _items[index] = item.copyWith(
                                        quantity: int.tryParse(value) ?? 1,
                                      );
                                    });
                                    _updateTotalAmount();
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _items.removeAt(index);
                                  });
                                  _updateTotalAmount();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    OutlinedButton.icon(
                      onPressed: _addNewItem,
                      icon: const Icon(Icons.add),
                      label: const Text('품목 추가'),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _totalAmountController,
                      decoration: const InputDecoration(
                        labelText: '총액',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          if (newValue.text.isEmpty) return newValue;
                          final number = int.parse(newValue.text);
                          final newString =
                              NumberFormat('#,###').format(number);
                          return TextEditingValue(
                            text: newString,
                            selection: TextSelection.collapsed(
                                offset: newString.length),
                          );
                        }),
                      ],
                      validator: (value) =>
                          value?.isEmpty ?? true ? '총액을 입력해주세요' : null,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _updateReceipt,
                      child: const Text('저장'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewItem() {
    setState(() {
      _items.add(ReceiptItem(
        name: '',
        price: 0,
        quantity: 1,
        totalPrice: 0,
      ));
    });
  }

  void _updateTotalAmount() {
    final total = _items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    _totalAmountController.text = NumberFormat('#,###').format(total);
  }

  void _updateReceipt() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedReceipt = widget.receipt.copyWith(
        merchantName: _merchantNameController.text,
        totalAmount:
            double.parse(_totalAmountController.text.replaceAll(',', '')),
        items: _items
            .map((item) => item.copyWith(
                  totalPrice: item.price * item.quantity,
                ))
            .toList(),
      );

      context.read<ReceiptBloc>().add(UpdateReceipt(updatedReceipt));
      Navigator.pop(context);
    }
  }
}
