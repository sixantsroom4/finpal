// lib/presentation/pages/expense/widgets/add_expense_fab.dart
import 'package:finpal/domain/entities/expense.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/expense/expense_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../bloc/expense/expense_bloc.dart';
import '../../../bloc/auth/auth_bloc.dart';

class AddExpenseFab extends StatelessWidget {
  const AddExpenseFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddExpenseDialog(context),
      child: const Icon(Icons.add),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    // 지출 추가 다이얼로그 표시
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddExpenseBottomSheet(),
    );
  }
}

// lib/presentation/pages/expense/widgets/add_expense_bottom_sheet.dart
class AddExpenseBottomSheet extends StatefulWidget {
  const AddExpenseBottomSheet({super.key});

  @override
  State<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<AddExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = '식비';

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            Text(
              '지출 추가',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '내용을 입력해주세요';
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
                DropdownMenuItem(value: '식비', child: Text('식비')),
                DropdownMenuItem(value: '교통', child: Text('교통')),
                DropdownMenuItem(value: '쇼핑', child: Text('쇼핑')),
                DropdownMenuItem(value: '여가', child: Text('여가')),
                DropdownMenuItem(value: '의료', child: Text('의료')),
                DropdownMenuItem(value: '기타', child: Text('기타')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? '식비';
                });
              },
            ),
            const SizedBox(height: 16),
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
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        final amount =
            double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;

        debugPrint('=== 지출 추가 시도 ===');
        debugPrint('내용: ${_descriptionController.text}');
        debugPrint('금액: $amount');
        debugPrint('카테고리: $_selectedCategory');
        debugPrint('유저 ID: ${authState.user.id}');

        context.read<ExpenseBloc>().add(
              AddExpense(
                Expense(
                  id: const Uuid().v4(),
                  userId: authState.user.id,
                  amount: amount,
                  description: _descriptionController.text,
                  category: _selectedCategory,
                  date: DateTime.now(),
                ),
              ),
            );

        Navigator.pop(context);

        // 스낵바 추가
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('지출이 추가되었습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        debugPrint('=== 오류: 인증되지 않은 사용자 ===');
      }
    } else {
      debugPrint('=== 오류: 폼 검증 실패 ===');
    }
  }
}
