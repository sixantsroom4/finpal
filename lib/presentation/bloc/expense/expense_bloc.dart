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

    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expenses) {
        final totalAmount =
            expenses.fold(0.0, (sum, expense) => sum + expense.amount);

        final categoryTotals = <String, double>{};
        for (var expense in expenses) {
          categoryTotals[expense.category] =
              (categoryTotals[expense.category] ?? 0.0) + expense.amount;
        }

        emit(ExpenseLoaded(
          expenses: expenses,
          totalAmount: totalAmount,
          monthlyBudget: 1000000.0, // 임시로 100만원 설정
          previousMonthTotal: 0.0, // 임시로 0원 설정
          categoryTotals: categoryTotals,
          userId: event.userId,
        ));

        // 추가 데이터 로드
        _loadAdditionalData(event.userId, emit);
      },
    );
  }

  Future<void> _loadAdditionalData(
      String userId, Emitter<ExpenseState> emit) async {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;

      final previousMonthResult =
          await _expenseRepository.getPreviousMonthExpenses(userId);
      final budgetResult = await _expenseRepository.getMonthlyBudget(userId);

      final previousMonthTotal = previousMonthResult.fold(
        (failure) => 0.0,
        (expenses) =>
            expenses.fold(0.0, (sum, expense) => sum + expense.amount),
      );

      final monthlyBudget = budgetResult.fold(
        (failure) => 1000000.0,
        (budget) => budget,
      );

      emit(ExpenseLoaded(
        expenses: currentState.expenses,
        totalAmount: currentState.totalAmount,
        monthlyBudget: monthlyBudget,
        previousMonthTotal: previousMonthTotal,
        categoryTotals: currentState.categoryTotals,
        userId: userId,
      ));
    }
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
        add(LoadExpenses(event.userId));
      },
    );
  }

  Future<void> _onLoadExpensesByDateRange(
    LoadExpensesByDateRange event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());

    // 현재 예산 값 보존
    double currentBudget = 0.0;
    if (state is ExpenseLoaded) {
      currentBudget = (state as ExpenseLoaded).monthlyBudget;
    }

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
          monthlyBudget: currentBudget, // 보존된 예산 값 사용
          previousMonthTotal: state is ExpenseLoaded
              ? (state as ExpenseLoaded).previousMonthTotal
              : 0.0,
          userId: event.userId,
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
          monthlyBudget: 0.0,
          previousMonthTotal: 0.0,
          userId: event.userId,
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
          userId: event.userId,
        )),
      );
    }
  }
}
