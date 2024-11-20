abstract class BudgetEvent {}

class LoadBudget extends BudgetEvent {
  final String userId;

  LoadBudget(this.userId);
}

class UpdateBudget extends BudgetEvent {
  final String userId;
  final double amount;

  UpdateBudget({required this.userId, required this.amount});
}
