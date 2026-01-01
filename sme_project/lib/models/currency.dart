class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });

  static const currencies = [
    Currency(code: 'USD', symbol: '\$', name: 'US Dollar'),
    Currency(code: 'EUR', symbol: '€', name: 'Euro'),
    Currency(code: 'GBP', symbol: '£', name: 'British Pound'),
    Currency(code: 'BRL', symbol: 'R\$', name: 'Brazilian Real'),
  ];

  static Currency findByCode(String code) {
    return currencies.firstWhere(
          (currency) => currency.code == code,
      orElse: () => currencies[0],
    );
  }
}