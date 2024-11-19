// lib/presentation/pages/subscription/widgets/add_subscription_bottom_sheet.dart
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/subscription/subscription_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/entities/subscription.dart';
import '../../../bloc/subscription/subscription_bloc.dart';
import '../../../bloc/auth/auth_bloc.dart';

class AddSubscriptionBottomSheet extends StatefulWidget {
  const AddSubscriptionBottomSheet({super.key});

  @override
  State<AddSubscriptionBottomSheet> createState() =>
      _AddSubscriptionBottomSheetState();
}

class _AddSubscriptionBottomSheetState
    extends State<AddSubscriptionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'OTT';
  String _selectedBillingCycle = 'monthly';
  int _selectedBillingDay = 1;

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
                  '구독 추가',
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
                if (double.tryParse(value!.replaceAll(',', '')) == null) {
                  return '올바른 금액을 입력해주세요';
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
              child: const Text('추가'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        final subscription = Subscription(
          id: const Uuid().v4(),
          name: _nameController.text,
          amount: double.parse(_amountController.text.replaceAll(',', '')),
          startDate: DateTime.now(),
          billingCycle: _selectedBillingCycle,
          billingDay: _selectedBillingDay,
          category: _selectedCategory,
          userId: authState.user.id,
          isActive: true,
        );

        context.read<SubscriptionBloc>().add(AddSubscription(subscription));
        Navigator.pop(context);
      }
    }
  }
}
