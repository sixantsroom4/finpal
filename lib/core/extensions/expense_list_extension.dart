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
}
