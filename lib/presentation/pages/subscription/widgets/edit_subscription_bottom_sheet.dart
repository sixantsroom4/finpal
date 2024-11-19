// lib/presentation/pages/subscription/widgets/edit_subscription_bottom_sheet.dart
import 'package:finpal/presentation/bloc/subscription/subscription_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/subscription.dart';
import '../../../bloc/subscription/subscription_bloc.dart';

class EditSubscriptionBottomSheet extends StatefulWidget {
  final Subscription subscription;

  const EditSubscriptionBottomSheet({
    super.key,
    required this.subscription,
  });

  @override
  State<EditSubscriptionBottomSheet> createState() =>
      _EditSubscriptionBottomSheetState();
}

class _EditSubscriptionBottomSheetState
    extends State<EditSubscriptionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late String _selectedCategory;
  late String _selectedBillingCycle;
  late int _selectedBillingDay;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subscription.name);
    _amountController = TextEditingController(
      text: widget.subscription.amount.toString(),
    );
    _selectedCategory = widget.subscription.category;
    _selectedBillingCycle = widget.subscription.billingCycle;
    _selectedBillingDay = widget.subscription.billingDay;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
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
                  '구독 수정',
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
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '서비스명',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '서비스명을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: '금액',
                border: OutlineInputBorder(),
                suffix: Text('원'),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '금액을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: '카테고리',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'OTT', child: Text('OTT')),
                DropdownMenuItem(value: 'MUSIC', child: Text('음악')),
                DropdownMenuItem(value: 'GAME', child: Text('게임')),
                DropdownMenuItem(value: 'FITNESS', child: Text('피트니스')),
                DropdownMenuItem(value: 'OTHER', child: Text('기타')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? 'OTT';
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedBillingCycle,
              decoration: const InputDecoration(
                labelText: '결제 주기',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'monthly', child: Text('월간')),
                DropdownMenuItem(value: 'yearly', child: Text('연간')),
                DropdownMenuItem(value: 'weekly', child: Text('주간')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedBillingCycle = value ?? 'monthly';
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedBillingDay,
              decoration: const InputDecoration(
                labelText: '결제일',
                border: OutlineInputBorder(),
              ),
              items: List.generate(
                28,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('${index + 1}일'),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedBillingDay = value ?? 1;
                });
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
      final updatedSubscription = Subscription(
        id: widget.subscription.id,
        name: _nameController.text,
        amount: double.parse(_amountController.text.replaceAll(',', '')),
        startDate: widget.subscription.startDate,
        billingCycle: _selectedBillingCycle,
        billingDay: _selectedBillingDay,
        category: _selectedCategory,
        userId: widget.subscription.userId,
        endDate: widget.subscription.endDate,
        isActive: widget.subscription.isActive,
      );

      context.read<SubscriptionBloc>().add(
            UpdateSubscription(updatedSubscription),
          );

      Navigator.pop(context);
    }
  }
}
