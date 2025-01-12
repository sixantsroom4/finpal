import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:finpal/core/constants/app_languages.dart';
import 'package:finpal/domain/entities/expense.dart';
import 'package:finpal/presentation/bloc/app_language/app_language_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/expense_repository.dart';
import 'expense_event.dart';
import 'expense_state.dart';
import '../../../data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository _expenseRepository;
  final AppLanguageBloc _appLanguageBloc;
  StreamSubscription<List<Expense>>? _expenseSubscription;
  final FirebaseFirestore _firestore;

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
    if (userId != null) {
      _expenseSubscription =
          _expenseRepository.watchExpenses(userId).listen((expenses) {
        add(UpdateExpenseList(expenses));
      });
    }
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());

    // 사용자의 선호 통화와 예산 정보 가져오기
    final userDoc =
        await _firestore.collection('users').doc(event.userId).get();
    final userModel = UserModel.fromJson(userDoc.data()!);
    final preferredCurrency = userModel.preferredCurrency;

    // 예산 정보 가져오기
    final budgetResult =
        await _expenseRepository.getMonthlyBudget(event.userId);

    // 현재 달의 시작일과 종료일 계산
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfNextMonth = DateTime(now.year, now.month + 1, 1);

    final result = await _expenseRepository.getExpensesByDateRange(
      event.userId,
      startOfMonth,
      startOfNextMonth,
    );

    final previousMonthResult =
        await _expenseRepository.getPreviousMonthExpenses(event.userId);

    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expenses) {
        // 사용자의 선호 통화와 일치하는 지출만 필터링
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
            // 이전 달도 동일하게 필터링
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
          userId: event.userId,
          monthlyTotals: state is ExpenseLoaded
              ? (state as ExpenseLoaded).monthlyTotals
              : {},
        ));
        _subscribeToExpenses(event.userId);
      },
    );
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());

    // 사용자의 선호 통화 가져오기
    final userDoc = await _firestore
        .collection('users')
        .doc(event.expenseModel.userId)
        .get();
    final userModel = UserModel.fromJson(userDoc.data()!);

    // 통화 정보가 포함된 새 지출 생성
    final expenseWithCurrency = event.expenseModel.copyWith(
      currency: userModel.preferredCurrency,
    );

    final result = await _expenseRepository.addExpense(expenseWithCurrency);

    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expense) {
        emit(const ExpenseOperationSuccess('지출이 추가되었습니다.'));
        add(LoadExpenses(event.expenseModel.userId));
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

        // 현재 월의 시작일과 종료일 계산
        final now = DateTime.now();
        final startDate = DateTime(now.year, now.month, 1);
        final endDate = DateTime(now.year, now.month + 1, 0);

        // 날짜 범위를 지정하 데이터 로드
        add(LoadExpensesByDateRange(
          userId: event.expense.userId,
          startDate: startDate,
          endDate: endDate,
        ));
      },
    );
  }

  Map<String, double> _calculateCategoryTotals(List<Expense> expenses) {
    final totals = <String, double>{};
    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0.0) + expense.amount;
    }
    return totals;
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
        emit(ExpenseOperationSuccess(_getLocalizedMessage('expense_deleted')));
        if (state is ExpenseLoaded) {
          final currentState = state as ExpenseLoaded;
          final updatedExpenses = currentState.expenses
              .where((expense) => expense.id != event.id)
              .toList();
          emit(currentState.copyWith(expenses: updatedExpenses));
        }
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

      // Firebase에서 현재 예산 값을 가져옴
      final budgetResult =
          await _expenseRepository.getMonthlyBudget(event.userId);

      if (event.amount > 0) {
        // 새로운 예산 값이 있는 경우에만 업데이트
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
        // 예산 값이 0이거나 없는 경우 Firebase에서 가져온 값 사용
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

  @override
  Future<void> close() {
    _expenseSubscription?.cancel();
    return super.close();
  }

  String _getLocalizedMessage(String key) {
    final language = _appLanguageBloc.state.language;
    final Map<String, Map<AppLanguage, String>> messages = {
      'expense_added': {
        AppLanguage.english: 'Expense has been added',
        AppLanguage.korean: '지출이 추가되었습니다',
        AppLanguage.japanese: '支出が追加されました',
      },
      'expense_updated': {
        AppLanguage.english: 'Expense has been updated',
        AppLanguage.korean: '지출이 수정되었습니다',
        AppLanguage.japanese: '支出が更新されました',
      },
      'expense_deleted': {
        AppLanguage.english: 'Expense has been deleted',
        AppLanguage.korean: '지출이 삭제되었습니다',
        AppLanguage.japanese: '支出が削除されました',
      },
    };
    return messages[key]?[language] ??
        messages[key]?[AppLanguage.korean] ??
        key;
  }
}
