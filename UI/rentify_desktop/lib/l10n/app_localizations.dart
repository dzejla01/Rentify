import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get _isBS => locale.languageCode == 'bs';

  // ---- Autentifikacija ----
  String get appName => 'Rentify';
  String get login => _isBS ? 'Prijava' : 'Login';
  String get logout => _isBS ? 'Odjava' : 'Logout';
  String get username => _isBS ? 'Korisničko ime' : 'Username';
  String get password => _isBS ? 'Lozinka' : 'Password';

  // ---- Navigacija ----
  String get properties => _isBS ? 'Nekretnine' : 'Properties';
  String get reservations => _isBS ? 'Rezervacije' : 'Reservations';
  String get payments => _isBS ? 'Zahtjevi plaćanja' : 'Payment requests';
  String get reports => _isBS ? 'Izvještaji' : 'Reports';
  String get reviews => _isBS ? 'Recenzije' : 'Reviews';
  String get appointments => _isBS ? 'Termini' : 'Appointments';
  String get questions => _isBS ? 'Pitanja' : 'Questions';
  String get expenses => _isBS ? 'Troškovi' : 'Expenses';
  String get referenceData => _isBS ? 'Šifarnici' : 'Reference data';
  String get notifications => _isBS ? 'Obavještenja' : 'Notifications';

  // ---- Troškovi ----
  String get newExpense => _isBS ? 'Novi trošak' : 'New expense';
  String get editExpense => _isBS ? 'Uredi trošak' : 'Edit expense';
  String get deleteExpense => _isBS ? 'Obriši trošak' : 'Delete expense';
  String get expenseDescription => _isBS ? 'Opis troška' : 'Expense description';
  String get expenseAmount => _isBS ? 'Iznos (KM)' : 'Amount (KM)';
  String get expenseCategory => _isBS ? 'Kategorija' : 'Category';
  String get expenseDate => _isBS ? 'Datum' : 'Date';
  String get totalExpenses => _isBS ? 'Ukupno troškova' : 'Total expenses';

  // ---- Opšte ----
  String get save => _isBS ? 'Spremi' : 'Save';
  String get cancel => _isBS ? 'Odustani' : 'Cancel';
  String get close => _isBS ? 'Zatvori' : 'Close';
  String get confirm => _isBS ? 'Potvrdi' : 'Confirm';
  String get search => _isBS ? 'Pretraži...' : 'Search...';
  String get noData => _isBS ? 'Nema podataka.' : 'No data.';
  String get loading => _isBS ? 'Učitavanje...' : 'Loading...';
  String get error => _isBS ? 'Greška' : 'Error';
  String get retry => _isBS ? 'Pokušaj ponovo' : 'Try again';
  String get language => _isBS ? 'Jezik' : 'Language';
  String get bosnian => _isBS ? 'Bosanski' : 'Bosnian';
  String get english => _isBS ? 'Engleski' : 'English';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'bs'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
