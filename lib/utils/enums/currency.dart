enum Currency {
  usd(name: "Dolar amerykański", value: "usd", sign: "\$", isLeftSigned: true),
  eur(name: "Euro", value: "eur", sign: "€", isLeftSigned: false),
  pln(name: "Polski złoty", value: "pln", sign: "ZŁ", isLeftSigned: false);

  const Currency(
      {required this.name,
      required this.value,
      required this.sign,
      required this.isLeftSigned});

  final String name;
  final String value;
  final String sign;
  final bool isLeftSigned;
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

  String formatAmount(double amount) {
    final formattedAmount = amount.toStringAsFixed(2);
    return isLeftSigned ? '$sign$formattedAmount' : '$formattedAmount $sign';
  }
}