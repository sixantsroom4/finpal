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
    on<UpdateMonthlyBudget>(_onUpdateMonthlyBudget);
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());

    final result = await _expenseRepository.getExpenses(event.userId);

    final previousMonthResult =
        await _expenseRepository.getPreviousMonthExpenses(event.userId);

    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expenses) {
        final categoryTotals = <String, double>{};
        for (var expense in expenses) {
          categoryTotals[expense.category] =
              (categoryTotals[expense.category] ?? 0.0) + expense.amount;
        }

        final previousMonthCategoryTotals = <String, double>{};
        previousMonthResult.fold(
          (failure) => {},
          (previousExpenses) {
            for (var expense in previousExpenses) {
              previousMonthCategoryTotals[expense.category] =
                  (previousMonthCategoryTotals[expense.category] ?? 0.0) +
                      expense.amount;
            }
          },
        );

        emit(ExpenseLoaded(
          expenses: expenses,
          totalAmount: expenses.fold(0.0, (sum, exp) => sum + exp.amount),
          monthlyBudget: state is ExpenseLoaded
              ? (state as ExpenseLoaded).monthlyBudget
              : 0.0,
          previousMonthTotal: previousMonthResult.fold(
            (failure) => 0.0,
            (expenses) => expenses.fold(0.0, (sum, exp) => sum + exp.amount),
          ),
          categoryTotals: categoryTotals,
          previousMonthCategoryTotals: previousMonthCategoryTotals,
          userId: event.userId,
          monthlyTotals: state is ExpenseLoaded
              ? (state as ExpenseLoaded).monthlyTotals
              : {},
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
        emit(const ExpenseOperationSuccess('출이 삭제되었습니다.'));
        add(LoadExpenses(event.userId));
      },
    );
  }

  Future<void> _onLoadExpensesByDateRange(
    LoadExpensesByDateRange event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());

    // 현재 예산 값 가져오기
    final budgetResult =
        await _expenseRepository.getMonthlyBudget(event.userId);

    final result = await _expenseRepository.getExpensesByDateRange(
      event.userId,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expenses) {
        final totalAmount = expenses.fold(0.0, (sum, exp) => sum + exp.amount);
        final categoryTotals = <String, double>{};

        for (final expense in expenses) {
          categoryTotals[expense.category] =
              (categoryTotals[expense.category] ?? 0) + expense.amount;
        }

        emit(ExpenseLoaded(
          expenses: expenses,
          totalAmount: totalAmount,
          categoryTotals: categoryTotals,
          monthlyBudget: budgetResult.fold(
            (failure) => state is ExpenseLoaded
                ? (state as ExpenseLoaded).monthlyBudget
                : 0.0,
            (budget) => budget,
          ),
          previousMonthTotal: state is ExpenseLoaded
              ? (state as ExpenseLoaded).previousMonthTotal
              : 0.0,
          previousMonthCategoryTotals: state is ExpenseLoaded
              ? (state as ExpenseLoaded).previousMonthCategoryTotals
              : {},
          userId: event.userId,
          monthlyTotals: state is ExpenseLoaded
              ? (state as ExpenseLoaded).monthlyTotals
              : {},
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
          monthlyBudget: state is ExpenseLoaded
              ? (state as ExpenseLoaded).monthlyBudget
              : 0.0,
          previousMonthTotal: state is ExpenseLoaded
              ? (state as ExpenseLoaded).previousMonthTotal
              : 0.0,
          categoryTotals: categoryTotals,
          previousMonthCategoryTotals: state is ExpenseLoaded
              ? (state as ExpenseLoaded).previousMonthCategoryTotals
              : {},
          userId: event.userId,
          monthlyTotals: state is ExpenseLoaded
              ? (state as ExpenseLoaded).monthlyTotals
              : {},
        ));
      },
    );
  }

  Future<void> _onUpdateMonthlyBudget(
    UpdateMonthlyBudget event,
    Emitter<ExpenseState> emit,
  ) async {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      final result = await _expenseRepository.updateMonthlyBudget(
        event.userId,
        event.amount,
      );

      result.fold(
        (failure) => emit(ExpenseError(failure.message)),
        (_) => emit(ExpenseLoaded(
          expenses: currentState.expenses,
          totalAmount: currentState.totalAmount,
          monthlyBudget: event.amount,
          previousMonthTotal: currentState.previousMonthTotal,
          categoryTotals: currentState.categoryTotals,
          previousMonthCategoryTotals: currentState.previousMonthCategoryTotals,
          monthlyTotals: currentState.monthlyTotals,
          userId: event.userId,
        )),
      );
    }
  }
}
