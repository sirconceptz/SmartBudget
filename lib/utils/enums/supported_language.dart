import 'dart:ui';

enum SupportedLanguage {
  english(Locale('en'), 'English'),
  polish(Locale('pl'), 'Polski'),
  spanish(Locale('es'), 'Español'),
  german(Locale('de'), 'Deutsch'),
  italian(Locale('it'), 'Italiano');

  final Locale locale;
  final String displayName;

  const SupportedLanguage(this.locale, this.displayName);
}
