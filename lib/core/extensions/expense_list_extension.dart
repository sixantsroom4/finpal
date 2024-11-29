import 'package:finpal/data/models/expense_model.dart';

extension ExpenseListExtension on List<ExpenseModel> {
  /// 통화별로 지출을 그룹화하고 각 통화별 합계를 계산합니다.
  Map<String, double> groupByCurrency() {
    final currencyTotals = <String, double>{};

    for (var expense in this) {
      currencyTotals.update(
        expense.currency,
        (total) => total + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return currencyTotals;
  }

  /// 특정 통화의 지출만 필터링합니다.
  List<ExpenseModel> filterByCurrency(String currency) {
    return where((expense) => expense.currency == currency).toList();
  }

  /// 특정 통화의 카테고리별 지출을 계산합니다.
  Map<String, double> getCategoryTotalsByCurrency(String currency) {
    final filtered = filterByCurrency(currency);
    final categoryTotals = <String, double>{};

    for (var expense in filtered) {
      categoryTotals.update(
        expense.category,
        (total) => total + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return categoryTotals;
  }
}
