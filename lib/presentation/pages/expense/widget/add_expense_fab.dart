// lib/presentation/pages/expense/widgets/add_expense_fab.dart
import 'package:finpal/core/utils/expense_category_constants.dart';
import 'package:finpal/data/models/expense_model.dart';
import 'package:finpal/data/models/user_model.dart';
import 'package:finpal/domain/entities/expense.dart';
import 'package:finpal/presentation/bloc/app_settings/app_settings_bloc.dart';
import 'package:finpal/presentation/bloc/auth/auth_state.dart';
import 'package:finpal/presentation/bloc/expense/expense_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../bloc/expense/expense_bloc.dart';
import '../../../bloc/auth/auth_bloc.dart';
import 'package:intl/intl.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/presentation/pages/expense/widget/add_expense_bottom_sheet.dart';

class AddExpenseFab extends StatelessWidget {
  const AddExpenseFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddExpenseBottomSheet(context),
      backgroundColor: const Color(0xFF2C3E50),
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 28,
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  void _showAddExpenseBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) => const AddExpenseBottomSheet(),
    );
  }
}
