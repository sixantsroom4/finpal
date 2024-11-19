import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/expense_repository.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository _expenseRepository;

  ExpenseBloc({
    required ExpenseRepository expenseRepository,
  })  : _expenseRepository = expenseRepository,
        super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<LoadExpensesByDateRange>(_onLoadExpensesByDateRange);
    on<LoadExpensesByCategory>(_onLoadExpensesByCategory);
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final result = await _expenseRepository.getExpenses(event.userId);

    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expenses) {
        final totalAmount = expenses.fold(
          0.0,
          (sum, expense) => sum + expense.amount,
        );

        final categoryTotals = <String, double>{};
        for (var expense in expenses) {
          categoryTotals[expense.category] =
              (categoryTotals[expense.category] ?? 0.0) + expense.amount;
        }

        emit(ExpenseLoaded(
          expenses: expenses,
          totalAmount: totalAmount,
          categoryTotals: categoryTotals,
        ));
      },
    );
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final result = await _expenseRepository.addExpense(event.expense);

    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expense) {
        emit(const ExpenseOperationSuccess('지출이 추가되었습니다.'));
        add(LoadExpenses(event.expense.userId));
      },
    );
  }

  Future<void> _onUpdateExpense(
    UpdateExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final result = await _expenseRepository.updateExpense(event.expense);

    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expense) {
        emit(const ExpenseOperationSuccess('지출이 수정되었습니다.'));
        add(LoadExpenses(event.expense.userId));
      },
    );
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final result = await _expenseRepository.deleteExpense(event.expenseId);

    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (_) {
        emit(const ExpenseOperationSuccess('지출이 삭제되었습니다.'));
        // 현재 상태가 ExpenseLoaded인 경우에만 userId를 가져와 목록을 다시 로드
        if (state is ExpenseLoaded) {
          final userId = (state as ExpenseLoaded).expenses.firstOrNull?.userId;
          if (userId != null) {
            add(LoadExpenses(userId));
          }
        }
      },
    );
  }

  Future<void> _onLoadExpensesByDateRange(
    LoadExpensesByDateRange event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final result = await _expenseRepository.getExpensesByDateRange(
      event.userId,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expenses) {
        final totalAmount = expenses.fold(
          0.0,
          (sum, expense) => sum + expense.amount,
        );

        final categoryTotals = <String, double>{};
        for (var expense in expenses) {
          categoryTotals[expense.category] =
              (categoryTotals[expense.category] ?? 0.0) + expense.amount;
        }

        emit(ExpenseLoaded(
          expenses: expenses,
          totalAmount: totalAmount,
          categoryTotals: categoryTotals,
        ));
      },
    );
  }

  Future<void> _onLoadExpensesByCategory(
    LoadExpensesByCategory event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final result = await _expenseRepository.getExpensesByCategory(
      event.userId,
      event.category,
    );

    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expenses) {
        final totalAmount = expenses.fold(
          0.0,
          (sum, expense) => sum + expense.amount,
        );

        final categoryTotals = <String, double>{};
        categoryTotals[event.category] = totalAmount;

        emit(ExpenseLoaded(
          expenses: expenses,
          totalAmount: totalAmount,
          categoryTotals: categoryTotals,
        ));
      },
    );
  }
}
