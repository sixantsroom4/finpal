class CurrencyUtils {
  /// 통화별 금액 포맷팅
  static String formatAmount(double amount, String currency) {
    switch (currency) {
      case 'KRW':
      case 'JPY':
        // 원화와 엔화는 소수점 없이 표시
        return amount.round().toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );

      case 'USD':
      case 'EUR':
        // 달러와 유로는 소수점 2자리까지 표시
        return amount.toStringAsFixed(2).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );

      default:
        return amount.toString();
    }
  }

  /// 통화 기호 가져오기
  static String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'KRW':
        return '₩';
      case 'USD':
        return '\$';
      case 'JPY':
        return '¥';
      case 'EUR':
        return '€';
      default:
        return currency;
    }
  }
}
