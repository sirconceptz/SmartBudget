enum Currency {
  usd(name: "Dolary amerykańskie", value: "usd"),
  eur(name: "Euro", value: "eur"),
  pln(name: "Polski złoty", value: "pln");

  const Currency({required this.name, required this.value});
  final String name;
  final String value;
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
