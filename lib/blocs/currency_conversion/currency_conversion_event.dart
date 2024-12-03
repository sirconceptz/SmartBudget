import 'package:equatable/equatable.dart';

abstract class CurrencyConversionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCurrencyRates extends CurrencyConversionEvent {
  final String baseCurrency;

  LoadCurrencyRates(this.baseCurrency);

  @override
  List<Object?> get props => [baseCurrency];
}
