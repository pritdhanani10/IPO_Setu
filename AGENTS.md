# IPOSetu - Workspace Rules & Architectural Guidelines

> **Application Name:** IPOSetu  
> **Tagline:** Your Bridge to New Opportunities  
> **Purpose:** Indian IPO information and allotment tracking platform (Android, iOS, Web).

---

## 1. Core Architecture

### Mobile App (`/ipo`)
* **Framework:** Flutter with Material 3 design tokens
* **Architecture:** Clean Architecture with feature modules (`core/`, `features/`, `shared/`)
* **State Management:** Flutter Riverpod
* **Networking:** Dio with `AuthInterceptor` (attaching Firebase ID tokens)
* **Navigation:** GoRouter with reactive auth state redirection
* **Secure Storage:** `flutter_secure_storage` for token and session management

### Backend (`/src`)
* **Framework:** ASP.NET Core Web API (.NET 8)
* **Architecture:** Clean Architecture (`IPOSetu.Domain`, `IPOSetu.Application`, `IPOSetu.Infrastructure`, `IPOSetu.API`)
* **Database:** PostgreSQL with Entity Framework Core
* **Token Verification:** Firebase Admin SDK (cryptographic ID token verification)
* **Data Sync:** Scheduled background services (`IpoDataSyncBackgroundService`) with official exchange providers (NSE, BSE)

---

## 2. Strict Data Integrity Rules

* **Zero Mock Data Policy:**
  * Absolutely **no mock data**, dummy data, fake IPOs, synthetic financial values, fake subscription metrics, or fake allotment outcomes.
  * If official or configured market data is not available, the app must display: **"Data currently unavailable"**.
* **Registrar & Allotment Rules:**
  * Never attempt to bypass CAPTCHA, scrape protected registrar portals, or generate fake allotment outcomes.
  * When programmatic checking is not available via an authorized partner API, the app must provide an official link redirecting the user to the verified registrar portal (Link Intime, KFintech, Bigshare, Skyline, Purva, Cameo, etc.) via `url_launcher`.
* **GMP Rules:**
  * Grey Market Premium (GMP) must only be shown if obtained from a legitimate, configured provider with clear attribution and update timestamp.
  * Otherwise, display: `GMP: Not Available`.

---

## 3. Authentication Constraints

* **Method:** Mobile Number + Firebase Phone OTP only.
* **Prohibited:**
  * No username, no email, no password.
  * No registration forms or profile completion screens.
* **User Identity:**
  * Users are identified internally solely by `FirebaseUid` and their verified mobile number.
  * Account provisioning occurs automatically via backend token exchange (`POST /api/auth/sync`).

---

## 4. Navigation & UX Constraints

* **Main Screen Navigation:**
  * Strictly **two main navigation tabs**:
    1. **Market** (Default selected tab)
    2. **Allotment**
  * Do not add Profile, Bids, or Portfolio as main navigation tabs.

---

## 5. Sensitive Data & PAN Security

* **Encryption at Rest:** All PAN records stored in the database must be encrypted using AES-256-GCM.
* **Masking:** PAN numbers sent to or displayed by the client must strictly be masked: `ABCDE****F`.
* **Logging:** Never log decrypted PAN numbers or secrets.
