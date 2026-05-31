# Rentify – Property rental app

## 📌 Introduction

Rentify je full-stack aplikacija za upravljanje iznajmljivanjem nekretnina koja omogućava korisnicima pregled i rezervaciju objekata, dok vlasnicima pruža kompletan sistem za upravljanje nekretninama, rezervacijama i plaćanjima.


Ovaj README fajl objašnjava:
- potrebne tehnologije
- način pokretanja projekta
- testne korisničke podatke
- opcije za testiranje aplikacije 

---

## 🛠️ Tehnologije i alati

Za provjeru i pokretanje projekta potrebno je imati instalirano:

- **Git**
- **Docker & Docker Compose**
- **Visual Studio (2022 ili noviji)**
- **Android Studio**
- **Flutter SDK**
- **.NET SDK (za backend, ako se ručno pokreće)**

---

## 📥 Kloniranje projekta

Projekat se preuzima sa GitHub repozitorija pomoću sljedeće komande:


git clone <GITHUB_REPO_LINK>



## 🔐 Konfiguracija (VAŽNO)

⚠️ **NAPOMENA ZA ENV**

Nakon `git clone`, u repozitoriju se nalazi **šifrirani fajl**: 

Env-postavke.7z


## ▶️ Pokretanje Stripe

Instalirajte Stripe CLI:
https://docs.stripe.com/stripe-cli/install

Provjerite instalaciju:
stripe --version

Ulogujte se na Stripe dashboard:
https://dashboard.stripe.com/login

Email: usertestni089@gmail.com
Password: USTestniER@!

U terminalu pokrenite:
stripe login

Pokrenite listener:
stripe listen --forward-to http://localhost:5002/api/payment/webhook


### Koraci:

🔐 **Šifra arhive:** `fit`

1. Otvoriti šifrirani fajl `Env-Postavke.7z`
2. Iz njega izvaditi fajl **`.env`**
3. **Prije pokretanja Dockera**, `.env` fajl ubaciti u **root folder projekta**  
   (folder gdje je urađen `git clone`)

⚠️ **Bez ovog koraka Docker servisi se neće pravilno pokrenuti.**

---

⚠️ **NAPOMENA ZA PUSH NOTOFIKACIJE**

Nakon `git clone`, u repozitoriju se nalazi **šifrirani fajl**: 

firebase-postavke.7z

### Koraci:

🔐 **Šifra arhive:** `fit`

1. Otvoriti šifrirani folder `firebase-postavke.7z`
2. Iz njega izvaditi folder **`firebase`**
3. **Prije pokretanja Dockera**, `firebase` folder ubaciti u **root folder projekta**  
   (folder gdje je urađen `git clone`)


## 🐳 Pokretanje Dockera

Kada su `.env` i `firebase` fajl pravilno postavljen, u terminalu (root folder projekta) pokrenuti:


docker compose up -d --build


## ▶️ Pokretanje aplikacije


U projektu se nalazi **šifrirani fajl**:
FIT-RS2-IB200024-Both-App.7z

🔐 **Šifra arhive:** `FIT`

Unutar arhive se nalaze:
- **Release/** – `.exe` fajl za pokretanje **desktop aplikacije**
- **flutter-apk/** – `.apk` fajl za pokretanje **mobilne aplikacije**

Ovo je **najbrži način** za testiranje aplikacije bez dodatne konfiguracije.

---


## 🧪 Testni korisnički podaci

### 🖥️ Desktop aplikacija

**Admin**
- Username: `owner1`
- Password: `Test123!`

## Email testiranje

Za testiranje dolaska maila na email dummy korisnika
"Darko Hodzic (owner1)" koristite:

- **Email:** `owner.testni@gmail.com`
- **Password:** `ownertestni123`



### 🖥️ Mobilna aplikacija

**Korisnik**

- Username: `user1`
- Password: `Test123!`

Za testiranje dolaska maila na email dummy korisnika
"Ivana Kovac (user1)" koristite:

- **Email:** `usertestni089@gmail.com`
- **Password:** `USTestniER@!`


NAPOMENA 

Molim Vas koristite ove podatke jer oporavak lozinke radi
na principu pronalaska maila koji je u registrovanim korisnicima
`







