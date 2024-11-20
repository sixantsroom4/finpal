import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/expense/expense_bloc.dart';
import '../../../bloc/expense/expense_event.dart';
import '../../../bloc/expense/expense_state.dart';
import 'package:intl/intl.dart';

class BudgetSettingsPage extends StatefulWidget {
  const BudgetSettingsPage({super.key});

  @override
  State<BudgetSettingsPage> createState() => _BudgetSettingsPageState();
}

class _BudgetSettingsPageState extends State<BudgetSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  final _numberFormat = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _initializeBudget();
  }

  void _initializeBudget() {
    final state = context.read<ExpenseBloc>().state;
    if (state is ExpenseLoaded) {
      _budgetController.text = _numberFormat.format(state.monthlyBudget);
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('월 예산 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  labelText: '월 예산',
                  border: OutlineInputBorder(),
                  suffix: Text('원'),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return '예산을 입력해주세요';
                  }
                  if (double.tryParse(value!.replaceAll(',', '')) == null) {
                    return '올바른 금액을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateBudget,
                child: const Text('저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateBudget() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_budgetController.text.replaceAll(',', ''));

      // 현재 사용자 ID와 함께 이벤트 추가
      final state = context.read<ExpenseBloc>().state;
      if (state is ExpenseLoaded) {
        context.read<ExpenseBloc>().add(UpdateMonthlyBudget(
              amount: amount,
              userId: state.userId,
            ));

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('월 예산이 설정되었습니다')),
        );
      }
    }
  }
}
