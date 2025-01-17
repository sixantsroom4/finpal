enum AppLocation {
  korea,
  japan,
  usa,
  europe,
}

extension AppLocationExtension on AppLocation {
  String get displayName {
    switch (this) {
      case AppLocation.korea:
        return '대한민국';
      case AppLocation.japan:
        return '日本';
      case AppLocation.usa:
        return 'USA';
      case AppLocation.europe:
        return 'Europe';
    }
  }

  String get currency {
    switch (this) {
      case AppLocation.korea:
        return 'KRW';
      case AppLocation.japan:
        return 'JPY';
      case AppLocation.usa:
        return 'USD';
      case AppLocation.europe:
        return 'EUR';
    }
  }
}
