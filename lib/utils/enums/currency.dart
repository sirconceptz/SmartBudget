import '../../l10n/app_localizations.dart';

enum Currency {
  usd(value: "usd", sign: "\$", isLeftSigned: true),
  eur(value: "eur", sign: "€", isLeftSigned: false),
  pln(value: "pln", sign: "ZŁ", isLeftSigned: false),
  jpy(value: "jpy", sign: "¥", isLeftSigned: true),
  gbp(value: "gbp", sign: "£", isLeftSigned: true),
  aud(value: "aud", sign: "\$", isLeftSigned: true),
  cad(value: "cad", sign: "\$", isLeftSigned: true),
  chf(value: "chf", sign: "CHF", isLeftSigned: false),
  cny(value: "cny", sign: "¥", isLeftSigned: true),
  hkd(value: "hkd", sign: "HK\$", isLeftSigned: true),
  nzd(value: "nzd", sign: "NZ\$", isLeftSigned: true);

  const Currency({
    required this.value,
    required this.sign,
    required this.isLeftSigned,
  });

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
      case 'jpy':
        return Currency.jpy;
      case 'gbp':
        return Currency.gbp;
      case 'aud':
        return Currency.aud;
      case 'cad':
        return Currency.cad;
      case 'chf':
        return Currency.chf;
      case 'cny':
        return Currency.cny;
      case 'hkd':
        return Currency.hkd;
      case 'nzd':
        return Currency.nzd;
      default:
        throw Exception('Invalid currency value');
    }
  }

  String localizedName(AppLocalizations localizations) {
    switch (this) {
      case Currency.usd:
        return localizations.currency_usd;
      case Currency.eur:
        return localizations.currency_eur;
      case Currency.pln:
        return localizations.currency_pln;
      case Currency.jpy:
        return localizations.currency_jpy;
      case Currency.gbp:
        return localizations.currency_gbp;
      case Currency.aud:
        return localizations.currency_aud;
      case Currency.cad:
        return localizations.currency_cad;
      case Currency.chf:
        return localizations.currency_chf;
      case Currency.cny:
        return localizations.currency_cny;
      case Currency.hkd:
        return localizations.currency_hkd;
      case Currency.nzd:
        return localizations.currency_nzd;
    }
  }

  String? formatAmount(double? amount) {
    if (amount == null) return null;
    final formattedAmount = amount.toStringAsFixed(2);
    return isLeftSigned ? '$sign$formattedAmount' : '$formattedAmount $sign';
  }
}
