import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/domain/entities/expense.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../domain/repositories/expense_repository.dart';
import 'expense_event.dart';
import 'expense_state.dart';
import '../../../data/models/user_model.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository _expenseRepository;
  final AppLanguageBloc _appLanguageBloc;
  StreamSubscription<List<Expense>>? _expenseSubscription;
  final FirebaseFirestore _firestore;
  DateTime? _currentStartDate;
  DateTime? _currentEndDate;

  ExpenseBloc({
    required ExpenseRepository expenseRepository,
    required AppLanguageBloc appLanguageBloc,
    required FirebaseFirestore firestore,
  })  : _expenseRepository = expenseRepository,
        _appLanguageBloc = appLanguageBloc,
        _firestore = firestore,
        super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<LoadExpensesByDateRange>(_onLoadExpensesByDateRange);
    on<LoadExpensesByCategory>(_onLoadExpensesByCategory);
    on<UpdateMonthlyBudget>(_onUpdateMonthlyBudget);
    on<UpdateExpenseList>(_onUpdateExpenseList);
  }

  void _subscribeToExpenses(String userId) {
    _expenseSubscription?.cancel();
    if (userId.isNotEmpty) {
      _expenseSubscription =
          _expenseRepository.watchExpenses(userId).listen((expenses) {
        if (_currentStartDate != null && _currentEndDate != null && !isClosed) {
          final filteredExpenses = expenses.where((expense) {
            final expenseDate = expense.date;
            return expenseDate.isAfter(_currentStartDate!) &&
                expenseDate
                    .isBefore(_currentEndDate!.add(const Duration(days: 1)));
          }).toList();
          if (!isClosed) {
            add(UpdateExpenseList(filteredExpenses));
          }
        }
      });
    }
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());

    final now = DateTime.now();
    _currentStartDate = DateTime(now.year, now.month, 1);
    _currentEndDate = DateTime(now.year, now.month + 1, 0);

    await _loadFilteredExpenses(event.userId, emit);
  }

  Future<void> _loadFilteredExpenses(
    String userId,
    Emitter<ExpenseState> emit,
  ) async {
    if (_currentStartDate == null || _currentEndDate == null) {
      emit(ExpenseError('날짜 범위가 설정되지 않았습니다.'));
      return;
    }

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userModel = UserModel.fromJson(userDoc.data()!);
    final preferredCurrency = userModel.preferredCurrency;

    final budgetResult = await _expenseRepository.getMonthlyBudget(userId);

    final result = await _expenseRepository.getExpensesByDateRange(
      userId,
      _currentStartDate!,
      _currentEndDate!,
    );

    final previousMonthResult =
        await _expenseRepository.getPreviousMonthExpenses(userId);

    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expenses) {
        final filteredExpenses = expenses
            .where((expense) => expense.currency == preferredCurrency)
            .toList();

        final categoryTotals = <String, double>{};
        for (var expense in filteredExpenses) {
          categoryTotals[expense.category] =
              (categoryTotals[expense.category] ?? 0.0) + expense.amount;
        }

        final previousMonthCategoryTotals = <String, double>{};
        previousMonthResult.fold(
          (failure) => {},
          (previousExpenses) {
            final filteredPreviousExpenses = previousExpenses
                .where((expense) => expense.currency == preferredCurrency)
                .toList();
            for (var expense in filteredPreviousExpenses) {
              previousMonthCategoryTotals[expense.category] =
                  (previousMonthCategoryTotals[expense.category] ?? 0.0) +
                      expense.amount;
            }
          },
        );

        // 최종적으로 ExpenseLoaded 상태 emit
        emit(ExpenseLoaded(
          expenses: filteredExpenses,
          totalAmount:
              filteredExpenses.fold(0.0, (sum, exp) => sum + exp.amount),
          monthlyBudget: budgetResult.fold(
            (failure) => state is ExpenseLoaded
                ? (state as ExpenseLoaded).monthlyBudget
                : 0.0,
            (budget) => budget,
          ),
          previousMonthTotal: previousMonthResult.fold(
            (failure) => 0.0,
            (expenses) => expenses
                .where((e) => e.currency == preferredCurrency)
                .fold(0.0, (sum, exp) => sum + exp.amount),
          ),
          categoryTotals: categoryTotals,
          previousMonthCategoryTotals: previousMonthCategoryTotals,
          userId: userId,
          monthlyTotals: state is ExpenseLoaded
              ? (state as ExpenseLoaded).monthlyTotals
              : {},
        ));
        _subscribeToExpenses(userId);
      },
    );
  }

  /// 수정된 AddExpense 핸들러: 모든 비동기 작업을 await 처리
  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());

    final userDoc = await _firestore
        .collection('users')
        .doc(event.expenseModel.userId)
        .get();
    final userModel = UserModel.fromJson(userDoc.data()!);

    final expenseWithCurrency = event.expenseModel.copyWith(
      currency: userModel.preferredCurrency,
    );

    final result = await _expenseRepository.addExpense(expenseWithCurrency);

    await result.fold(
      (failure) async {
        emit(ExpenseError(failure.message));
      },
      (expense) async {
        // 추가 후 최신 데이터 로드를 통해 UI 갱신
        await _loadFilteredExpenses(event.expenseModel.userId, emit);
        // 추가 메시지는 SnackBar 등으로 별도 UI 처리 (BlocListener 활용 권장)
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
        final now = DateTime.now();
        final startDate = DateTime(now.year, now.month, 1);
        final endDate = DateTime(now.year, now.month + 1, 0);
        add(LoadExpensesByDateRange(
          userId: event.expense.userId,
          startDate: startDate,
          endDate: endDate,
        ));
      },
    );
  }

  /// 수정된 DeleteExpense 핸들러: 삭제 직후 로딩 상태를 먼저 emit하고, 최신 데이터를 await 한 뒤에 최종적으로 성공 상태로 전환
  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final result = await _expenseRepository.deleteExpense(event.expenseId);
    await result.fold(
      (failure) async {
        emit(ExpenseError(failure.message));
      },
      (_) async {
        // 삭제 직후 로딩 상태 후 최신 데이터를 불러오기
        await _loadFilteredExpenses(event.userId!, emit);
        // 최종적으로 성공 상태를 따로 emit하지 않고, 최신 데이터를 반영한 ExpenseLoaded 상태가 나오도록 함
        // (SnackBar 등은 UI 단 BlocListener에서 처리 권장)
      },
    );
  }

  Future<void> _onLoadExpensesByDateRange(
    LoadExpensesByDateRange event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    _currentStartDate = event.startDate;
    _currentEndDate = event.endDate;
    await _loadFilteredExpenses(event.userId, emit);
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
        final totalAmount =
            expenses.fold(0.0, (sum, expense) => sum + expense.amount);
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
      final budgetResult =
          await _expenseRepository.getMonthlyBudget(event.userId);

      if (event.amount > 0) {
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
            previousMonthCategoryTotals:
                currentState.previousMonthCategoryTotals,
            userId: currentState.userId,
            monthlyTotals: currentState.monthlyTotals,
          )),
        );
      } else {
        budgetResult.fold(
          (failure) => emit(ExpenseError(failure.message)),
          (budget) => emit(ExpenseLoaded(
            expenses: currentState.expenses,
            totalAmount: currentState.totalAmount,
            monthlyBudget: budget,
            previousMonthTotal: currentState.previousMonthTotal,
            categoryTotals: currentState.categoryTotals,
            previousMonthCategoryTotals:
                currentState.previousMonthCategoryTotals,
            userId: currentState.userId,
            monthlyTotals: currentState.monthlyTotals,
          )),
        );
      }
    }
  }

  Future<void> _onUpdateExpenseList(
    UpdateExpenseList event,
    Emitter<ExpenseState> emit,
  ) async {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      if (!emit.isDone) {
        emit(ExpenseLoaded(
          expenses: event.expenses,
          totalAmount: event.expenses.fold(0.0, (sum, exp) => sum + exp.amount),
          monthlyBudget: currentState.monthlyBudget,
          previousMonthTotal: currentState.previousMonthTotal,
          categoryTotals: _calculateCategoryTotals(event.expenses),
          previousMonthCategoryTotals: currentState.previousMonthCategoryTotals,
          userId: currentState.userId,
          monthlyTotals: currentState.monthlyTotals,
        ));
      }
    }
  }

  Map<String, double> _calculateCategoryTotals(List<Expense> expenses) {
    final totals = <String, double>{};
    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0.0) + expense.amount;
    }
    return totals;
  }

  @override
  Future<void> close() {
    _expenseSubscription?.cancel();
    return super.close();
  }
}
