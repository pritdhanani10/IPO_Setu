# IPOSetu - Indian IPO Information & Allotment Tracking

> **Tagline:** *Your Bridge to New Opportunities*

---

## Overview

**IPOSetu** is a production-grade mobile application and backend platform built for tracking Indian Mainboard and SME Initial Public Offerings (IPOs) and checking multi-PAN allotment statuses.

The application strictly enforces **Zero Mock Data**, **Zero Fake Allotment Results**, and **Mobile Number + Firebase Phone OTP Only** authentication.

```text
┌─────────────────────────────────────────────────────────┐
│                      IPOSetu Mobile                     │
│               Flutter (Android & iOS)                   │
│        Material 3 • Riverpod • Dio • GoRouter           │
├────────────────────────────┬────────────────────────────┤
│           Market           │          Allotment         │
│   (Open, Upcoming, Closed, │  (Multi-PAN Management,    │
│     Listed, Mainboard/SME) │   Official Registrar Links)│
└────────────────────────────┴────────────────────────────┘
                              │
                    HTTPS / Firebase Token
                              ▼
┌─────────────────────────────────────────────────────────┐
│                 ASP.NET Core Web API                    │
│            Clean Architecture (.NET 8/9)                │
│    Domain • Application • Infrastructure • API          │
├─────────────────────────────────────────────────────────┤
│ • Firebase ID Token Verification (Admin SDK)            │
│ • AES-256-GCM PAN Encryption at Rest                    │
│ • Scheduled Background Data Sync (NSE, BSE, Registrars) │
│ • Entity Framework Core + PostgreSQL                    │
└─────────────────────────────────────────────────────────┘
```

---

## 1. Application Structure

The mobile interface is intentionally focused on two primary operational tabs:

1. **Market** (Default):
   - Status filters: **Open**, **Upcoming**, **Closed**, **Listed**.
   - Category filters: **All**, **Mainboard**, **SME**.
   - Real-time search by company name and symbol.
   - Price bands, calculated minimum investments (`Upper Price × Lot Size`), issue sizes, and dates.
   - Real subscription metrics (Retail, QIB, NII/HNI, Total) displayed only when available from official sources.
   - Grey Market Premium (GMP) displayed strictly with source attribution and disclaimer when provided by a configured legitimate provider; otherwise shows `GMP: Not Available`.
   - Action buttons: `[ MORE INFORMATION ]` and `[ ALLOTMENT ]`.
   - Strict Empty & Fallback State: Shows **"Data currently unavailable"** whenever official data is not synchronized.
2. **Allotment**:
   - **Your PAN Cards**: Add multiple PAN cards with optional labels (e.g., "My PAN", "Family PAN 1").
   - **Multi-PAN Allotment Checking**: Select an IPO and multiple PAN cards with checkboxes.
   - **Official Website Fallback**: When an authorized programmatic API is not available, opens the official registrar allotment portal (Link Intime, KFintech, Bigshare, etc.) using `url_launcher`.
   - Never generates synthetic allotment results or bypasses CAPTCHAs.

---

## 2. Authentication Flow

The application exclusively uses **Firebase Phone Number OTP Authentication**.

```text
Open IPOSetu
      ↓
Check Firebase Login Session
      ↓
Already Logged In?
   ↙             ↘
 YES             NO
  ↓               ↓
Market       Enter Mobile Number (+91)
                    ↓
              Send Firebase OTP
                    ↓
               Enter 6-Digit OTP
                    ↓
             Verify with Firebase
                    ↓
           Get Firebase ID Token
                    ↓
      Send Token to Backend (/api/auth/sync)
                    ↓
       Backend verifies Firebase Token
                    ↓
       Automatically Create/Update User
                    ↓
               Open Market
```

- **No username**, **no email**, **no password**, and **no profile setup screens**.
- Users are identified internally by `FirebaseUid`.
- Verified phone numbers are securely extracted directly from the verified Firebase ID Token claims.

---

## 3. Data & Security Rules

- **Zero Mock Data Policy**: Hardcoded IPO records, dummy financials, and placeholder subscription data are completely prohibited.
- **PAN Security at Rest**:
  - Full PAN numbers are encrypted using **AES-256-GCM** with unique 12-byte nonces and 16-byte authentication tags.
  - Plain PANs are never logged, never exposed to unauthorized services, and never stored unencrypted.
  - Client displays strictly masked PANs: `ABCDE****F`.
- **Allotment Fallback**:
  - Direct integration with verified official registrar portals:
    - **Link Intime**: `https://linkintime.co.in/initial_offer/public-issues.html`
    - **KFintech**: `https://ris.kfintech.com/ipostatus/`
    - **Bigshare Services**: `https://ipo.bigshareonline.com/`
    - **Skyline Financial**: `https://www.skylinerta.com/ipo.php`
    - **Purva Sharegistry**: `https://www.purvashare.com/investor-service/ipo-query`
    - **Cameo Corporate**: `https://ipo.cameoindia.com/`
    - **Maashitla Securities**: `https://maashitla.com/allotment-status/public-issues`

---

## 4. Backend Clean Architecture

```text
IPOSetu.sln
  src/
    IPOSetu.Domain/
      Entities/ (User, SavedPan, Ipo, IpoSubscription, IpoFinancial, IpoDocument, DataSyncLog)
      Interfaces/ (IUserRepository, ISavedPanRepository, IIpoRepository, IPanEncryptionService, IIpoDataProvider, IAllotmentProvider)
    IPOSetu.Application/
      DTOs/ (AuthDtos, IpoDtos, PanDtos, AllotmentDtos)
      Interfaces/ (IAuthService, IIpoService, IPanService, IAllotmentService)
      Services/ (AuthService, IpoService, PanService, AllotmentService)
    IPOSetu.Infrastructure/
      Persistence/ (ApplicationDbContext, Repositories)
      Encryption/ (AesGcmPanEncryptionService)
      Firebase/ (FirebaseAdminService)
      DataProviders/ (NseIpoProvider, BseIpoProvider, CompositeIpoDataProvider, OfficialAllotmentProvider, RegistrarRegistry)
      BackgroundServices/ (IpoDataSyncBackgroundService)
    IPOSetu.API/
      Controllers/ (AuthController, IposController, PansController, AllotmentController)
      Middleware/ (FirebaseAuthMiddleware, ExceptionHandlingMiddleware)
      Program.cs
```

### Running the Backend

#### Option A: Docker Compose (PostgreSQL + API)
```bash
docker-compose up --build -d
```
- Swagger UI will be available at: `http://localhost:5000/swagger`
- PostgreSQL is running at: `localhost:5432`

#### Option B: .NET CLI
```bash
# In project root
dotnet restore
dotnet run --project src/IPOSetu.API
```

---

## 5. Mobile Application (Flutter)

### Prerequisites
- Flutter SDK (3.13.2+)
- Android Studio / Xcode
- Firebase Project configured (`iposetu`)

### Running the App
```bash
cd ipo
flutter pub get
flutter run
```

### Running Unit & Widget Tests
```bash
flutter test
```

---

## 6. API Endpoints

### Authentication
- `POST /api/auth/sync` - Verifies Firebase ID token and auto-provisions or updates the user account.

### IPO Market Data
- `GET /api/ipos` - List IPOs (Query params: `status=open|upcoming|closed|listed`, `category=mainboard|sme`, `search=...`)
- `GET /api/ipos/{id}` - Full IPO details (company profile, timeline, offer structure, lead managers)
- `GET /api/ipos/{id}/subscription` - Subscription metrics
- `GET /api/ipos/{id}/financials` - Historical financial statements (Revenue, EBITDA, PAT, EPS)
- `GET /api/ipos/{id}/documents` - Official DRHP, RHP, and prospectus documents

### PAN Management (Requires Firebase Auth)
- `GET /api/pans` - List user's saved masked PAN cards
- `POST /api/pans` - Add a new PAN (validates `[A-Z]{5}[0-9]{4}[A-Z]{1}`, encrypts with AES-256)
- `PUT /api/pans/{id}` - Update PAN label
- `DELETE /api/pans/{id}` - Remove a saved PAN

### Allotment Checking (Requires Firebase Auth)
- `POST /api/allotment/check` - Checks allotment across selected PAN cards. Returns authorized status or directs user to official registrar portal.

---

## 7. Statutory Disclaimer

> **Disclaimer:**
> IPOSetu is an information and tracking platform and does not provide investment advice. IPO information is obtained from configured official or authorized data sources. Data availability and update frequency depend on the source. GMP is unofficial market information and may vary.

