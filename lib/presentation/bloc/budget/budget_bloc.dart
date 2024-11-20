import 'package:finpal/domain/services/budget_service.dart';
import 'package:finpal/presentation/bloc/budget/budget_event.dart';
import 'package:finpal/presentation/bloc/budget/budget_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetService _budgetService;

  BudgetBloc(this._budgetService) : super(BudgetInitial()) {
    on<LoadBudget>(_onLoadBudget);
    on<UpdateBudget>(_onUpdateBudget);
  }

  Future<void> _onLoadBudget(
      LoadBudget event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    final result = await _budgetService.getBudget(event.userId);

    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (budget) => emit(BudgetLoaded(budget)),
    );
  }

  Future<void> _onUpdateBudget(
      UpdateBudget event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    final result =
        await _budgetService.updateBudget(event.userId, event.amount);

    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (_) => add(LoadBudget(event.userId)),
    );
  }
}
