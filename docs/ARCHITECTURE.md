# Architecture & Flow Diagrams

## 1. Application Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         PRESENTATION                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                 Screens (UI Layer)                    │  │
│  │  - Splash Screen      - Login Screen                 │  │
│  │  - Onboarding Screen  - Register Screen              │  │
│  │  - Home Screen                                        │  │
│  └──────────────────────────────────────────────────────┘  │
│                            ↕                                 │
│  ┌──────────────────────────────────────────────────────┐  │
│  │            State Management (Providers)               │  │
│  │  - AuthProvider       - OnboardingProvider           │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                          DOMAIN                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                       Models                          │  │
│  │  - OnboardingModel    - User (future)                │  │
│  │  - Report (future)                                    │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                           DATA                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Local Storage (Current)                  │  │
│  │  - SharedPreferences                                  │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Remote API (Future)                      │  │
│  │  - Auth API       - Report API                       │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 2. Authentication Flow

```
┌──────────────┐
│  App Start   │
└──────┬───────┘
       │
       ▼
┌──────────────┐      3 seconds
│Splash Screen │─────────────────┐
└──────────────┘                 │
                                 ▼
                    ┌─────────────────────────┐
                    │ Check Onboarding Status │
                    └────────┬────────────────┘
                             │
                ┌────────────┴────────────┐
                ▼                         ▼
         [Not Complete]            [Complete]
                │                         │
                ▼                         ▼
    ┌─────────────────────┐   ┌──────────────────┐
    │ Onboarding Screen   │   │ Check Auth Status│
    └────────┬────────────┘   └────────┬─────────┘
             │                          │
             │ Skip/Complete   ┌────────┴────────┐
             │                 ▼                 ▼
             │          [Authenticated]   [Not Authenticated]
             │                 │                 │
             └─────────────────┼─────────────────┘
                               ▼
                    ┌─────────────────────┐
                    │   Login Screen      │
                    └────────┬────────────┘
                             │
                    ┌────────┴─────────┐
                    ▼                  ▼
            ┌──────────────┐   ┌──────────────┐
            │    Login     │   │   Register   │
            └──────┬───────┘   └──────┬───────┘
                   │                  │
                   └────────┬─────────┘
                            │
                            ▼
                  ┌──────────────────┐
                  │   Home Screen    │
                  └──────────────────┘
```

## 3. State Management Flow (Provider)

```
┌─────────────┐
│ User Action │ (e.g., Click Login Button)
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│   Widget (Screen)   │
│                     │
│  context.read<      │
│   AuthProvider>()   │
│   .login(...)       │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│   AuthProvider      │
│                     │
│  1. _isLoading=true │
│  2. notifyListeners │
│  3. Call API        │
│  4. Update state    │
│  5. notifyListeners │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│  All Listeners      │
│  (Consumer widgets) │
│                     │
│  builder() called   │
│  → UI Rebuilds      │
└─────────────────────┘
```

## 4. Navigation Flow (go_router)

```
Route Change Request
        │
        ▼
┌───────────────────┐
│   GoRouter        │
│  - Check redirect │
└────────┬──────────┘
         │
         ▼
   ┌────────────┐
   │  Redirect? │
   └─┬────────┬─┘
     │        │
    Yes       No
     │        │
     ▼        ▼
┌─────────┐  ┌──────────────┐
│Navigate │  │Build Screen  │
│to other │  └──────────────┘
└─────────┘
```

## 5. Screen Lifecycle

```
┌──────────────────┐
│  Screen Created  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   initState()    │ ← Initialize controllers, load data
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│     build()      │ ← Build widget tree
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Screen Displayed │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  User Interacts  │ ← setState() / Provider updates
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   build() again  │ ← Rebuild with new data
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   dispose()      │ ← Cleanup controllers, listeners
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Screen Destroyed │
└──────────────────┘
```

## 6. Login Flow Detail

```
┌─────────────────┐
│  Login Screen   │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│ User fills form:        │
│ - Email                 │
│ - Password              │
│ Click "Masuk"           │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│ Form Validation         │
└────┬───────────────┬────┘
     │               │
   Valid         Invalid
     │               │
     ▼               ▼
┌─────────────┐  ┌──────────────┐
│Call Provider│  │Show Error Msg│
│.login()     │  └──────────────┘
└─────┬───────┘
      │
      ▼
┌──────────────────────┐
│ Show Loading         │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ Validate Credentials │
│ (Mock for now)       │
└──┬──────────────┬────┘
   │              │
 Success       Failure
   │              │
   ▼              ▼
┌────────────┐ ┌──────────────┐
│Save to     │ │Show Error    │
│SharedPrefs │ │Message       │
└─────┬──────┘ └──────────────┘
      │
      ▼
┌──────────────┐
│Navigate to   │
│Home Screen   │
└──────────────┘
```

## 7. File Dependencies

```
main.dart
    │
    ├─→ providers/
    │       ├─→ auth_provider.dart
    │       └─→ onboarding_provider.dart
    │
    ├─→ routes/
    │       └─→ app_router.dart
    │               │
    │               ├─→ screens/splash_screen.dart
    │               ├─→ screens/onboarding_screen.dart
    │               ├─→ screens/login_screen.dart
    │               ├─→ screens/register_screen.dart
    │               └─→ screens/home_screen.dart
    │
    └─→ constants/
            ├─→ colors.dart
            └─→ text_styles.dart

All screens use:
    ├─→ constants/colors.dart
    ├─→ constants/text_styles.dart
    └─→ providers/ (as needed)
```

## 8. Data Flow: Login Example

```
┌─────────────────┐
│  LoginScreen    │
│                 │
│  User Input:    │
│  email@test.com │
│  password123    │
└────────┬────────┘
         │
         │ context.read<AuthProvider>().login(email, pass)
         ▼
┌─────────────────────────────────────┐
│  AuthProvider                       │
│                                     │
│  1. _isLoading = true              │
│  2. notifyListeners()              │  ◄─┐
│  3. Validate email format          │    │
│  4. Check password length          │    │ Listeners
│  5. [Future] Call API              │    │ Rebuild
│  6. Save to SharedPreferences      │    │
│  7. _userEmail = email             │    │
│  8. _status = authenticated        │    │
│  9. _isLoading = false             │    │
│  10. notifyListeners()             │  ──┘
└────────┬────────────────────────────┘
         │
         │ Returns: true/false
         ▼
┌─────────────────┐
│  LoginScreen    │
│                 │
│  if success:    │
│  → context.go   │
│    ('/home')    │
│                 │
│  if failed:     │
│  → Show error   │
└─────────────────┘
```

## 9. Folder Structure Visualization

```
lib/
│
├── constants/              # Reusable constants
│   ├── colors.dart        # Color palette
│   └── text_styles.dart   # Typography
│
├── models/                 # Data structures
│   └── onboarding_model.dart
│
├── providers/              # State management
│   ├── auth_provider.dart       # Auth state
│   └── onboarding_provider.dart # Onboarding state
│
├── routes/                 # Navigation config
│   └── app_router.dart     # GoRouter setup
│
├── screens/                # UI pages
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   └── home_screen.dart
│
├── widgets/                # Reusable components
│   └── (future widgets)
│
└── main.dart              # App entry point
```

## 10. Future Architecture (Planned)

```
┌─────────────────────────────────────────┐
│           PRESENTATION                  │
│  ┌────────────────────────────────┐    │
│  │  Screens + Widgets             │    │
│  └───────────┬────────────────────┘    │
│              ↕                          │
│  ┌────────────────────────────────┐    │
│  │  Providers (State Management)  │    │
│  └───────────┬────────────────────┘    │
└──────────────┼─────────────────────────┘
               ↕
┌──────────────┼─────────────────────────┐
│              │      DOMAIN             │
│  ┌───────────┴────────────────────┐   │
│  │  Models + Business Logic       │   │
│  └───────────┬────────────────────┘   │
└──────────────┼─────────────────────────┘
               ↕
┌──────────────┼─────────────────────────┐
│              │        DATA             │
│  ┌───────────┴────────────────────┐   │
│  │  Repositories                  │   │
│  └───┬─────────────────┬──────────┘   │
│      ↕                 ↕               │
│  ┌────────────┐  ┌────────────┐       │
│  │ Local DB   │  │ Remote API │       │
│  │(SQLite)    │  │(REST/GQL)  │       │
│  └────────────┘  └────────────┘       │
└─────────────────────────────────────────┘
```

---

## Notes

- **Current**: Basic architecture dengan Provider pattern
- **Future**: Will add Repository pattern untuk data layer
- **Scalable**: Easy to extend dengan fitur baru
- **Testable**: Clear separation of concerns

## Legend

```
┌─────┐
│ Box │  = Component/Layer
└─────┘

  ↕     = Two-way communication
  →     = One-way flow
  ◄─    = Callback/Event
```
