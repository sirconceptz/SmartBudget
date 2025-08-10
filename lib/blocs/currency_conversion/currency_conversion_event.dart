import 'package:equatable/equatable.dart';

abstract class CurrencyConversionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCurrencyRates extends CurrencyConversionEvent {
  LoadCurrencyRates();
}

class BackgroundRefreshCurrencyRates extends CurrencyConversionEvent {
  final int attempts;

  BackgroundRefreshCurrencyRates({this.attempts = 2});
}
