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
  String get register => _isBS ? 'Registracija' : 'Register';
  String get username => _isBS ? 'Korisničko ime' : 'Username';
  String get password => _isBS ? 'Lozinka' : 'Password';
  String get forgotPassword => _isBS ? 'Zaboravili ste lozinku?' : 'Forgot password?';
  String get emailAddress => _isBS ? 'Email adresa' : 'Email address';
  String get sendCode => _isBS ? 'Pošalji kod' : 'Send code';
  String get changePassword => _isBS ? 'Promijeni lozinku' : 'Change password';

  // ---- Navigacija ----
  String get properties => _isBS ? 'Nekretnine' : 'Properties';
  String get reservations => _isBS ? 'Rezervacije' : 'Reservations';
  String get payments => _isBS ? 'Plaćanja' : 'Payments';
  String get appointments => _isBS ? 'Termini' : 'Appointments';
  String get favorites => _isBS ? 'Favoriti' : 'Favorites';
  String get profile => _isBS ? 'Profil' : 'Profile';
  String get notifications => _isBS ? 'Obavještenja' : 'Notifications';
  String get map => _isBS ? 'Mapa' : 'Map';

  // ---- Nekretnine ----
  String get propertyDetails => _isBS ? 'Detalji nekretnine' : 'Property details';
  String get pricePerMonth => _isBS ? 'Cijena/mj.' : 'Price/month';
  String get pricePerNight => _isBS ? 'Cijena/noć' : 'Price/night';
  String get squareMeters => _isBS ? 'Kvadratura' : 'Square meters';
  String get available => _isBS ? 'Dostupno' : 'Available';
  String get notAvailable => _isBS ? 'Nije dostupno' : 'Not available';
  String get whyRecommended => _isBS ? 'Zašto je preporučeno?' : 'Why recommended?';

  // ---- Rezervacije ----
  String get makeReservation => _isBS ? 'Rezervacija?' : 'Reserve?';
  String get monthly => _isBS ? 'Najamnina' : 'Monthly rent';
  String get shortStay => _isBS ? 'Kratki boravak' : 'Short stay';
  String get cancelReservation => _isBS ? 'Otkaži rezervaciju' : 'Cancel reservation';
  String get confirmCancel => _isBS
      ? 'Da li ste sigurni da želite otkazati ovu rezervaciju?'
      : 'Are you sure you want to cancel this reservation?';

  // ---- Plaćanje ----
  String get payNow => _isBS ? 'Plati sada' : 'Pay now';
  String get paid => _isBS ? 'Plaćeno' : 'Paid';
  String get pending => _isBS ? 'Na čekanju' : 'Pending';
  String get cancelled => _isBS ? 'Otkazano' : 'Cancelled';
  String get failed => _isBS ? 'Neuspješno' : 'Failed';

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
