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

⚠️ **NAPOMENA**

Nakon `git clone`, u repozitoriju se nalazi **šifrirani fajl**: 

Env-postavke.7z

### Koraci:

🔐 **Šifra arhive:** `FIT`

1. Otvoriti šifrirani fajl `EnviormentalPostavke.7z`
2. Iz njega izvaditi fajl **`.env`**
3. **Prije pokretanja Dockera**, `.env` fajl ubaciti u **root folder projekta**  
   (folder gdje je urađen `git clone`)

⚠️ **Bez ovog koraka Docker servisi se neće pravilno pokrenuti.**

---

## 🐳 Pokretanje Dockera

Kada je `.env` fajl pravilno postavljen, u terminalu (root folder projekta) pokrenuti:


docker compose up -d --build




## ▶️ Pokretanje aplikacije


U projektu se nalazi **šifrirani fajl**:
FIT-RS2-IB200024-DesktopApp.7z

🔐 **Šifra arhive:** `FIT`

Unutar arhive se nalaze:
- **Release/** – `.exe` fajl za pokretanje **desktop aplikacije**

Ovo je **najbrži način** za testiranje aplikacije bez dodatne konfiguracije.

---


## 🧪 Testni korisnički podaci

### 🖥️ Desktop aplikacija

**Admin**
- Username: `owner1`
- Password: `Test123!`

## Email testiranje

Za testiranje dolaska maila na email dummy korisnika
"Marko Petrov (owner1)" koristite:

- **Email:** `owner.testni@gmail.com`
- **Password:** `ownertestni123`

NAPOMENA 

Molim Vas koristite ove podatke jer oporavak lozinke radi
na principu pronalaska maila koji je u registrovanim korisnicima
`







