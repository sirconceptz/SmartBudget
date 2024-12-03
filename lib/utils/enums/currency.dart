enum Currency {
  usd(name: "Dolary amerykańskie", value: "usd", sign: "\$"),
  eur(name: "Euro", value: "eur", sign: "€"),
  pln(name: "Polski złoty", value: "pln", sign: "ZŁ");

  const Currency({required this.name, required this.value, required this.sign});

  final String name;
  final String value;
  final String sign;
}

extension CurrencyExtension on Currency {
  static Currency fromString(String value) {
    switch (value) {
      case 'usd':
        return Currency.usd;
      case 'eur':
        return Currency.eur;
      case 'pln':
        return Currency.pln;
      default:
        throw Exception('Invalid currency value');
    }
  }
}
