# Ispravke Rentify projekta

---

## Greška 2 — Uklanjanje SMTP kredencijala iz source koda
**Fajl:** `Rentify.EmailConsumer/Program.cs`  
**Promjena:** Uklonjene fallback vrijednosti `owner.testni@gmail.com` i `jvbirwmajapudpcm` za SMTP_USER i SMTP_PASS. Sada aplikacija baca `InvalidOperationException` ako env varijable nisu postavljene, umjesto da koristi hardkodirane kredencijale.

---

## Greška 3 — Zaključavanje UserController po self/admin pravilima
**Fajl:** `Rentify.WebAPI/Controllers/UserController.cs`  
**Promjena:** Dodane auth anotacije:
- `Get` (listanje) — samo `Admin`
- `GetById` — samo `Admin` ili sam korisnik (provjera ID-a)
- `Update` — samo `Admin` ili vlasnik profila
- `Delete` — samo `Admin`

---

## Greška 4 — Ne vjerovati UserId iz Flutter requesta
**Fajlovi:** `ReservationController`, `AppointmentController`, `FavoriteController`, `QuestionController`, `AnswerController`, `PropertyController`, `PaymentController`  
**Promjena:** U svakom od ovih kontrolera, `UserId` se sada preuzima iz JWT tokena i prepisuje vrijednost iz requesta. Korisnik više ne može slati tuđi UserId.

---

## Greška 5 — Ownership provjere za vlasničke akcije
**Fajlovi:** `Rentify.Services/Services/ReservationService.cs`, `Rentify.WebAPI/Controllers/ReportController.cs`  
**Promjena:**
- `ReservationService`: Dodana `CheckPropertyOwnershipAsync` metoda — provjerava da li je prijavljeni korisnik vlasnik nekretnine prije `ApproveAsync`, `FinishAsync`, `RejectAsync`.
- `ReportController.GetIncomeReport`: Za korisnike sa rolom `Vlasnik`, `OwnerId` se sada preuzima iz JWT tokena umjesto iz query parametra.

---

## Greška 6 — Ograničenje generičkog CRUD-a za PaymentController
**Fajlovi:** `Rentify.WebAPI/Controllers/PaymentController.cs`, `Rentify.Services/Services/PaymentService.cs`  
**Promjena:**
- `Get` — filtrira po `UserId` za ne-admin korisnike
- `GetById` — provjerava da korisnik može vidjeti samo vlastite uplate
- `Create` — samo `Admin` i `Vlasnik`
- `Update` — samo `Admin`
- `Delete` — samo `Admin`
- `GetByIdAsync` u `PaymentService` sada include-uje `Reservation` za ownership provjeru

---

## Greška 7 — Zaštita upload i brisanja slika
**Fajlovi:** `Rentify.WebAPI/Controllers/ImageController.cs`, `Rentify.Services/Services/ImageService.cs`  
**Promjena:**
- `ImageController` — dodan `[Authorize]` na klasi
- `ImageService.NormalizeFolder` — dodan whitelist foldera (`users`, `properties`); baca `ArgumentException` za nedozvoljene foldere
- `ImageService.SaveAsync` — dodana magic-bytes validacija slike (provjera stvarnog sadržaja fajla, ne samo ekstenzije)

---

## Greška 8 — Ispravka pravila za recenzije
**Fajlovi:** `Rentify.Services/Services/ReviewService.cs`, `Rentify.WebAPI/Controllers/ReviewController.cs`  
**Promjena:**
- Recenzija dozvoljena samo za rezervacije sa statusom `Završeno` (ne više `Odobreno`)
- Provjera da recenziju piše korisnik koji je napravio rezervaciju (`BeforeInsert`)
- `BeforeUpdate` provjerava da korisnik može mijenjati samo vlastitu recenziju (ili admin)
- Dodan `BeforeDelete` — samo autor ili admin može brisati recenziju
- `ReviewController` — dodane `[Authorize(Roles = "Korisnik")]` i `[Authorize(Roles = "Korisnik,Admin")]` anotacije

---

## Greška 9 — Ispravka logike pitanja i odgovora
**Fajl:** `Rentify.Services/Services/AnswerService.cs`  
**Promjena:**
- `BeforeInsert` provjerava da vlasnik odgovara samo na pitanja za vlastite nekretnine
- Dodat check za dupli odgovor — baca `InvalidOperationException` ako pitanje već ima odgovor
- `BeforeDelete` — vraća `IsAnswered = false` na pitanju kada se odgovor briše

---

## Greška 10 — In-app notifikacije (dopuna)
**Fajlovi (backend):** `Rentify.Services/Services/AppointmentService.cs`, `Rentify.Services/Services/ReservationService.cs`, `Rentify.Services/Services/UserService.cs`  
**Fajlovi (desktop):** `rentify_desktop/lib/models/notification_item.dart`, `rentify_desktop/lib/providers/notification_provider.dart`, `rentify_desktop/lib/screens/notification_screen.dart`, `rentify_desktop/lib/routes/app_routes.dart`, `rentify_desktop/lib/main.dart`, `rentify_desktop/lib/screens/home_screen.dart`  
**Promjena:**

**Backend:**
- `AppointmentService` — dodata zavisnost `INotificationService`; notifikacija se šalje korisniku pri: odobrenju, odbijanju, otkazivanju i završetku termina; notifikacija se šalje vlasniku nekretnine pri kreiranju novog zahtjeva za termin
- `ReservationService.CreateAsync` — šalje notifikaciju vlasniku nekretnine: „Nova rezervacija" kada korisnik kreira zahtjev za rezervaciju
- `UserService` — dodata zavisnost `INotificationService`; `ResetPasswordAsync` šalje notifikaciju korisniku „Lozinka promijenjena" nakon uspješnog reseta lozinke

**Desktop aplikacija:**
- Kreiran ekran za notifikacije sa auto-refresh svakih 30 sekundi, mark-as-read funkcionalnostima i badge-om nepročitanih
- Dodat bell-icon u header `HomeScreen` sa crvenim badge-om koji prikazuje broj nepročitanih notifikacija; klik otvara ekran notifikacija

---

## Greška 11 — Audit trag i razlog odbijanja/otkazivanja
**Fajlovi:** `Rentify.Services/Services/ReservationService.cs`, `Rentify.Services/Interfaces/IReservationService.cs`, `Rentify.WebAPI/Controllers/ReservationController.cs`, `Rentify.Model/RequestObjects/ReasonRequest.cs`  
**Promjena:**
- `RejectAsync` i `CancelAsync` primaju opcionalni `reason` parametar
- Na svakoj promjeni statusa (`ApproveAsync`, `FinishAsync`, `RejectAsync`, `CancelAsync`) zapisuje se `ReservationHistory` unos sa novim statusom, razlogom i identifikatorom korisnika
- API endpoint-i `reject` i `cancel` primaju body `{ "reason": "..." }`
- Kreiran novi `ReasonRequest.cs` request klasa

---

## Greška 12 — Payment idempotentnost
**Fajl:** `Rentify.Services/Services/PaymentService.cs`  
**Promjena:**
- `HandlePaymentIntentSucceededAsync` — provjera ako je već `Plaćeno`, metoda se završava bez efekata
- `CreateNewPaymentIntentAsync` — blokira kreiranje novog intenta ako je status `Procesiranje` i već postoji Stripe intent ID
- `GetPaymentFromMetadataAsync` — ne prepisuje `StripePaymentIntentId` ako je već postavljen

---

## Greška 13 — PaymentService.BeforeUpdate koristi stari status
**Fajl:** `Rentify.Services/Services/PaymentService.cs`  
**Promjena:** `BeforeUpdate` sada koristi `request.PaymentStatus` (novi status iz requesta) umjesto `entity.PaymentStatus` (starog statusa) za određivanje da li treba postaviti/obrisati `PaidAt`.

---

## Greška 14 — Tok zaboravljene lozinke
**Fajlovi:** `Rentify.Services/Services/UserService.cs`  
**Promjena:**
- `ForgotPasswordAsync` ne baca više `NotFoundException` ako email ne postoji — vraća se bez greške (isti odgovor u oba slučaja, sprečava otkrivanje registrovanih emailova)
- RabbitMQ channel se sada pravilno dispose-a (`await using var channel`)

---

## Greška 15 — Refaktoring: Referentne tabele za City, Status i BuildingType
**Fajlovi (backend):**
- Novi entiteti: `City.cs`, `Status.cs`, `BuildingType.cs`
- `Property.cs` — `City: string` → `CityId: int` + `City? City` navigacijski + `BuildingTypeId: int` + `BuildingType? BuildingType`
- `Reservation.cs`, `Appointment.cs`, `Payment.cs`, `ReservationHistory.cs` — `Status/PaymentStatus: string` → `StatusId: int` + `Status? Status`
- `RentifyDbContext.cs` — dodani `DbSet<City>`, `DbSet<Status>`, `DbSet<BuildingType>` i FK relacije
- Novi modeli: `CityResponse`, `StatusResponse`, `BuildingTypeResponse`, `CityUpsertRequest`, `BuildingTypeUpsertRequest`, `CitySearchObject`, `StatusSearchObject`, `BuildingTypeSearchObject`
- `PropertyInsertRequest`, `PropertyUpdateRequest`, `PropertyResponse`, `PropertySearchObject` — mijenjaju string City/BuildingType u int CityId/BuildingTypeId
- `ReservationResponse`, `AppointmentResponse`, `PaymentResponse` — mijenjaju string Status/PaymentStatus u int StatusId + StatusResponse objekat
- `ReservationSearchObject`, `AppointmentSearchObject`, `PaymentSearchObject` — mijenjaju string Status u int StatusId
- `AppointmentUpsertRequest`, `PaymentUpsertRequest` — mijenjaju string Status u int StatusId = 1 (default Pending)
- Novi servisi i interfejsi: `CityService`, `StatusService`, `BuildingTypeService`
- Novi kontroleri: `CityController`, `StatusController`, `BuildingTypeController`
- Svi string usporedbe statusa u servisima (PropertyService, ReservationService, AppointmentService, PaymentService, ReviewService, ReportService) i state machine klasama zamijenjeni integerima (1=Na čekanju, 2=Odobreno, 3=Završeno, 4=Odbijeno, 5=Otkazano, 6=Procesiranje, 7=Plaćeno, 8=Neplaćeno, 9=Neuspješno)
- `SeedData.cs` — dodana seed data za City/Status/BuildingType tabele; Property seed koristi `CityId`/`BuildingTypeId`; Reservation/Appointment/Payment seed koristi `StatusId`
- `Program.cs` — registrovani novi servisi (`ICityService`, `IStatusService`, `IBuildingTypeService`)
- Kreirana EF migracija: `AddCityStatusBuildingType`

---

## Greška 16 — Mapa nekretnina
**Fajlovi (backend):** `Rentify.Services/Database/Property.cs`, `Rentify.Model/ResponseObjects/PropertyResponse.cs`, `Rentify.Services/Database/SeedData.cs`, `Rentify.Services/Migrations/20260529200000_AddLatLngAndExpense.cs`  
**Fajlovi (mobile):** `UI/rentify_mobile/lib/models/property.dart`, `UI/rentify_mobile/lib/models/property.g.dart`, `UI/rentify_mobile/lib/screens/property_map_screen.dart`, `UI/rentify_mobile/lib/routes/app_routes.dart`, `UI/rentify_mobile/lib/screens/property_screen.dart`  
**Promjena:**
- Dodana polja `Latitude?` i `Longitude?` (nullable double) u `Property` entitet i `PropertyResponse`
- Seed data generira koordinate na osnovu grada (Sarajevo, Mostar, Tuzla, Banja Luka, Zenica, Bihać) sa malim ofsetima po nekretnini
- Kreirana migracija `AddLatLngAndExpense` koja dodaje kolone u bazu
- Kreiran `PropertyMapScreen` koristeći `flutter_map` i `latlong2` — prikazuje sve aktivne nekretnine kao markere; nekretnine bez GPS koordinata koriste koordinate svog grada kao fallback, klik otvara karticu sa detaljima
- Dodan FAB dugme "Mapa" u `PropertyScreen`

---

## Greška 16 — Evidencija troškova
**Fajlovi (backend):** `Rentify.Services/Database/Expense.cs`, `Rentify.Model/RequestObjects/ExpenseUpsertRequest.cs`, `Rentify.Model/ResponseObjects/ExpenseResponse.cs`, `Rentify.Model/SearchObjects/ExpenseSearchObject.cs`, `Rentify.Services/Interfaces/IExpenseService.cs`, `Rentify.Services/Services/ExpenseService.cs`, `Rentify.WebAPI/Controllers/ExpenseController.cs`, `Rentify.Services/Database/RentifyDbContext.cs`, `Rentify.WebAPI/Program.cs`  
**Fajlovi (desktop):** `UI/rentify_desktop/lib/models/expense.dart`, `UI/rentify_desktop/lib/models/expense.g.dart`, `UI/rentify_desktop/lib/providers/expense_provider.dart`, `UI/rentify_desktop/lib/screens/expense_screen.dart`, `UI/rentify_desktop/lib/routes/app_routes.dart`, `UI/rentify_desktop/lib/main.dart`, `UI/rentify_desktop/lib/screens/home_screen.dart`  
**Promjena:**
- Kreiran `Expense` entitet sa poljima: UserId, PropertyId (opcionalno), Description, Amount, Date, Category, CreatedAt
- Implementiran puni CRUD backend: servis, interfejs, kontroler (pristup samo `Vlasnik` i `Admin`)
- Kategorije: Održavanje, Popravak, Komunalije, Osiguranje, Porez, Ostalo
- Kreiran desktop `ExpenseScreen` sa tabelarnim prikazom, filterom po kategoriji, kartama ukupnih troškova i dijalogom za dodavanje/uređivanje
- Dodan "Troškovi" card na dashboard `HomeScreen`

---

## Greška 16 — Dvojezičnost (bosanski/engleski)
**Fajlovi (mobile):** `UI/rentify_mobile/pubspec.yaml`, `UI/rentify_mobile/lib/l10n/app_localizations.dart`, `UI/rentify_mobile/lib/l10n/app_bs.arb`, `UI/rentify_mobile/lib/l10n/app_en.arb`, `UI/rentify_mobile/lib/main.dart`  
**Fajlovi (desktop):** `UI/rentify_desktop/pubspec.yaml`, `UI/rentify_desktop/lib/l10n/app_localizations.dart`, `UI/rentify_desktop/lib/l10n/app_bs.arb`, `UI/rentify_desktop/lib/l10n/app_en.arb`, `UI/rentify_desktop/lib/main.dart`  
**Promjena:**
- Dodan `flutter_localizations` paket (Flutter SDK) u oba projekta; `intl` verzija unaprijeđena na `^0.20.2`
- Kreirana ručna `AppLocalizations` klasa sa podrškom za bosanski (`bs`) i engleski (`en`) — bez potrebe za `flutter gen-l10n`
- ARB fajlovi sadrže sve ključne UI stringove (prijava, navigacija, nekretnine, rezervacije, plaćanje, troškovi, opšti pojmovi)
- `MaterialApp` u oba projekta ažuriran sa `localizationsDelegates`, `supportedLocales` i zadanim lokalitetom `bs`
- Svi sistemski widgeti (date pickeri, dugmad dijaloga) automatski se lokaliziraju na bosanski

---

## Greška 17 — Mobile ekran za reset lozinke
**Status:** Već implementiran — `ForgotPasswordDialog` u `UI/rentify_mobile/lib/dialogs/forgot_password_dialog.dart` sadrži kompletan tok: email → kod iz emaila → nova lozinka, usklađen sa backend reset-token pristupom iz Greške 14.

---

## Greška 18 — Objašnjenje preporuka u recommenderu
**Fajl:** `UI/rentify_mobile/lib/screens/property_details_screen.dart`  
**Promjena:** Dodan `_InfoCard` widget koji prikazuje `whyRecommended` polje (ako nije prazno) između sekcije tagova i detalja, sa ikonom sijalice i zelenom bojom — korisnik vidi razlog zašto mu je nekretnina preporučena.

---

## Greška 19 — Paginacija i zaštita list endpointa
**Fajlovi:** `Rentify.Services/Services/BaseService.cs`, `Rentify.WebAPI/Controllers/BaseController.cs`  
**Promjena:**
- `BaseService.GetAsync` — default `PageSize` = 10, maksimalni limit = 100; negativne `Page` vrijednosti se normalizuju na 0
- `BaseController.Get` — `RetrieveAll = true` se ignoruje za ne-admin korisnike

---

## Greška 20 — State machine prelazi
**Fajlovi:** `Rentify.WebAPI/Controllers/ReservationController.cs`, `Rentify.Services/AppointmentStateMachine/PendingAppointmentState.cs`, `Rentify.WebAPI/Program.cs`  
**Promjena:**
- `ReservationController.Update` sada baca `NotSupportedException` (vraća HTTP 405)
- `PendingAppointmentState.AllowedActions` — uklonjen `ToFinishedAsync` (završavanje nije dozvoljeno iz stanja "Na čekanju")
- `Program.cs` — dodan handler za `NotSupportedException` → HTTP 405

---

## Greška 21 — Usklađivanje datuma
**Fajlovi:** `ReservationHistory.cs`, `Answer.cs`, `Favorite.cs`, `Question.cs`, `ReservationService.cs`, `ReportService.cs`  
**Promjena:**
- Svi `DateTime.Now` zamijenjeni sa `DateTime.UtcNow` u entity klasama
- `GetUnavailableReservationDatesAsync` — interval je sada `[start, end)` (`day < end` umjesto `day <= end`), što znači da checkout dan nije zauzet

---

## Greška 22 — UI validacija i potvrde za nepovratne akcije
**Fajlovi:** `UI/rentify_mobile/lib/screens/property_appointment_screen.dart`  
**Promjena:**
- `_validateForm()` — uklonjen dupli `SnackbarHelper.showError` poziv; greške se prikazuju **isključivo inline** kroz `_validationCard()` koji je već bio implementiran
- Plaćanje (`payment_preview_screen.dart`) — već ima `_confirmAndPay` s `ConfirmDialogs.yesNoConfirmation` prije `_payNow`
- Otkazivanje rezervacije (`reservation_list_screen.dart`) — već ima `_showCancelReservationDialog` s potvrdom

---

## Greška 23 — Ispravka izvještaja
**Fajlovi:** `Rentify.Services/Services/ReportService.cs`  
**Promjena:**
- `GetBestOwnerByYearAsync` — filtrira samo rezervacije sa statusom `Završeno` ili `Odobreno`; odbijene i otkazane rezervacije više ne ulaze u izvještaj

---

## Greška 24 — RabbitMQ worker ispravke
**Fajl:** `Rentify.EmailConsumer/Consumer/EmailQueueConsumer.cs`  
**Promjena:**
- `Console.WriteLine` zamijenjen sa `ILogger<EmailQueueConsumer>` (`_logger.LogError`)
- `ILogger` se injektuje kroz konstruktor

---

## Greška 25 — Refaktoring status stringova u stabilne kodove
**Fajlovi:** Pokriveno u sklopu Greške 15 — svi servisi, state machine klase i Flutter UI fajlovi koji su koristili lokalizovane stringove statusa  
**Promjena:**
- Svi string statusi (`"Na čekanju"`, `"Odobreno"`, `"Završeno"`, `"Plaćeno"`, `"Procesiranje"` itd.) u backend servisima, state machine klasama i filterima zamijenjeni stabilnim integer kodovima
- Mapiranje: 1=Na čekanju, 2=Odobreno, 3=Završeno, 4=Odbijeno, 5=Otkazano, 6=Procesiranje, 7=Plaćeno, 8=Neplaćeno, 9=Neuspješno
- Lokalizovani prikaz statusa ostaje isključivo u Flutter UI sloju (response objekti sadrže `Status.Name` za prikaz, a logika koristi `StatusId`)
- Kreirana referentna tabela `Status` u bazi — jedino mjesto gdje se čuvaju nazivi statusa; backend logika nikad ne uspoređuje stringove

---

## Greška 26 — Jedna glavna slika po nekretnini
**Fajl:** `Rentify.Services/Services/PropertyImageService.cs`  
**Promjena:**
- `BeforeInsert` — ako nova slika ima `IsMain = true`, sve ostale slike za isti `PropertyId` postavljaju se na `IsMain = false`
- `BeforeUpdate` — isto pravilo pri ažuriranju

---

## Greška 27 — Code quality: typo nazivi i namespace
**Fajlovi:** `DataBaseConfiguration.cs`, `AppointmentUpserRequest.cs`, `PropertyImageUpsersRequest.cs`, `ReviewUpserRequest.cs`, `ApprovedAppoitmentState.cs`, `CosinuseSimilarityHelper.cs`  
**Promjena:**
- Namespace `eTravelAgencija.Services.Database` u `DataBaseConfiguration.cs` → `Rentify.Services.Database`
- Preimenovani fajlovi:
  - `AppointmentUpserRequest.cs` → `AppointmentUpsertRequest.cs`
  - `PropertyImageUpsersRequest.cs` → `PropertyImageUpsertRequest.cs`
  - `ReviewUpserRequest.cs` → `ReviewUpsertRequest.cs`
  - `ApprovedAppoitmentState.cs` → `ApprovedAppointmentState.cs`
  - `CosinuseSimilarityHelper.cs` → `CosineSimilarityHelper.cs`

---

## Dodatna ispravka — Dinamički odabir mjeseci u izvještajima
**Fajl:** `UI/rentify_desktop/lib/screens/report_screen.dart`  
**Promjena:**
- `_incomeMonthOptions` — umjesto hardkodiranog `List.generate(4, ...)` za 2026, koristi se `DateTime.now().month` pa se prikazuju svi prošli i tekući mjeseci tekuće godine; za prethodne godine prikazuje se svih 12 mjeseci
- `_incomeYearOptions` — umjesto hardkodiranog `const [2025, 2026]`, dinamički generira listu godina od 2025. do tekuće godine; lista se automatski proširuje svake nove godine
