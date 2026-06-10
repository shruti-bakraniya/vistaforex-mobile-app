# VistaForex

[Download Android APK](https://github.com/shruti-bakraniya/vistaforex-mobile-app/releases/download/v0.0.1/vistaforex_v1.apk)

**Premium Flutter currency converter with glassmorphism UI, GetX MVVM, and real-time exchange rates.**

> A mobile-first currency converter featuring live/cached/offline exchange rates from multiple API providers, interactive rate-history charts, a conversion ledger, and a glassmorphism design system with full dark/light mode support.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture Overview](#architecture-overview)
- [Directory Structure](#directory-structure)
- [App Flow](#app-flow)
- [State Management](#state-management)
- [Data Layer](#data-layer)
- [Theming & Design System](#theming--design-system)
- [Getting Started](#getting-started)

---

## Features

| Feature | Description |
|---|---|
| **Currency Conversion** | Convert between 18 currencies with real-time cross-rate calculation |
| **Rate History** | Interactive area charts for 7 / 30 / 90 / 365-day historical data |
| **Conversion Ledger** | Locally persisted log of saved conversions, searchable and grouped by date |
| **Multi-Source Rates** | Switch between Frankfurter (ECB) and Open Exchange Rates providers |
| **Offline Support** | Three-tier connectivity: Live → Cached → Fallback rates with visual indicators |
| **Glassmorphism UI** | Frosted-glass app bar, bottom nav, cards, and overlays |
| **Dark / Light Mode** | Manual toggle with a curated dual palette (`VfColors`) |
| **Sparkline & Stats** | 30-day mini sparkline on the convert screen with hi/lo/% change |
| **Settings** | Data source selector, sync interval, and offline-cache toggle |

---

## Tech Stack

| Package | Version | Role |
|---|---|---|
| **Flutter SDK** | `^3.12.1` | Framework |
| **get** | `^4.7.3` | State management, DI, and reactive bindings |
| **dio** | `^5.9.2` | HTTP client with interceptors (connectivity guard, error normalizer) |
| **fl_chart** | `^1.2.0` | Interactive area charts on the History screen |
| **shared_preferences** | `^2.5.5` | Local key-value persistence (rates cache, ledger, settings) |
| **connectivity_plus** | `^7.1.1` | Real-time network connectivity detection |
| **intl** | `^0.20.2` | Number and date formatting |

---

## Architecture Overview

VistaForex follows an **MVVM (Model-View-ViewModel)** architecture powered by **GetX**. Each feature is self-contained with its own Controller (ViewModel) and View, while shared state flows through a central `HomeController`.

```
┌──────────────────────────────────────────────────────────────┐
│                        Presentation                          │
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐ │
│  │ Convert  │  │ History  │  │  Ledger  │  │   Settings   │ │
│  │  View    │  │  View    │  │  View    │  │    View      │ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └──────┬───────┘ │
│       │              │             │               │         │
│  ┌────┴─────┐  ┌────┴─────┐  ┌────┴─────┐  ┌──────┴───────┐ │
│  │ Convert  │  │ History  │  │ Ledger   │  │  Settings    │ │
│  │Controller│  │Controller│  │Controller│  │ Controller   │ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └──────┬───────┘ │
│       │              │             │               │         │
│       └──────────────┴──────┬──────┴───────────────┘         │
│                             │                                │
│                    ┌────────┴────────┐                        │
│                    │ HomeController  │  ← Central state hub   │
│                    └────────┬────────┘                        │
└─────────────────────────────┼────────────────────────────────┘
                              │
┌─────────────────────────────┼────────────────────────────────┐
│                        Data Layer                            │
│                             │                                │
│              ┌──────────────┴──────────────┐                 │
│              │  ExchangeRateRepository     │                 │
│              │  (singleton, cache-aware)    │                 │
│              └──────┬──────────────┬───────┘                 │
│                     │              │                          │
│          ┌──────────┴───┐  ┌──────┴──────────┐               │
│          │ Frankfurter  │  │ OpenER Provider │               │
│          │  Provider    │  │                 │               │
│          └──────────────┘  └─────────────────┘               │
│                                                              │
│              ┌─────────────────────────┐                     │
│              │   LedgerRepository      │                     │
│              │ (SharedPreferences)     │                     │
│              └─────────────────────────┘                     │
└──────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────┼────────────────────────────────┐
│                        Core Layer                            │
│                             │                                │
│   ┌─────────────┐  ┌───────┴──────┐  ┌───────────────────┐  │
│   │ CacheService│  │  DioClient   │  │ConnectivityService│  │
│   │(SharedPrefs)│  │(interceptors)│  │  (GetxService)    │  │
│   └─────────────┘  └──────────────┘  └───────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Single source of truth** — `HomeController` owns the canonical currency pair (`fromCode`, `toCode`), amount, exchange rates map, and connectivity state. Feature controllers read from it via `Get.find<HomeController>()`.
2. **Reactive bindings** — GetX `.obs` observables automatically rebuild only the widgets that depend on them; `ever()` workers chain side-effects (e.g., reload sparkline when the pair changes).
3. **Offline-first** — The `ExchangeRateRepository` tries network → disk cache → hardcoded fallback, so the app never shows an empty state.
4. **Feature-scoped controllers** — Each screen has its own controller for UI-specific state (swap animation, chart range selection, search query, etc.) while delegating shared mutations to `HomeController`.

---

## Directory Structure

```
lib/
├── main.dart                          # Entry point: orientation lock, system UI, cache init
│
├── app/                               # App-level configuration
│   ├── app.dart                       # GetMaterialApp root widget + initial binding
│   ├── colors.dart                    # VfColors semantic color palette (light + dark)
│   └── theme.dart                     # AppTheme — Material 3 ThemeData builder
│
├── core/                              # Infrastructure services (singletons)
│   ├── cache_service.dart             # SharedPreferences wrapper (string, json, list)
│   ├── connectivity_service.dart      # GetxService wrapping connectivity_plus
│   └── dio_client.dart                # Dio singleton with connectivity + error interceptors
│
├── data/                              # Data layer: models, repositories, API providers
│   ├── models.dart                    # Currency, RatePoint, ConversionEntry, ApiSource, etc.
│   ├── currencies.dart                # 18 currencies list, flag/symbol metadata, fallback rates
│   ├── api_sources.dart               # Registry of available API sources with metadata
│   ├── exchange_rate_repository.dart   # Orchestrator: network → cache → fallback for rates & history
│   ├── frankfurter_provider.dart      # Frankfurter API (ECB) — latest rates + time-series history
│   ├── open_er_provider.dart          # Open Exchange Rates API — latest rates only
│   └── ledger_repository.dart         # CRUD for saved conversions via SharedPreferences
│
├── features/                          # Feature modules (MVVM per screen)
│   ├── home/
│   │   ├── home_binding.dart          # GetX Bindings — registers all controllers (lazyPut, fenix)
│   │   ├── home_controller.dart       # Central state: rates, pair, amount, connectivity, tab nav
│   │   └── home_view.dart             # Shell: AppBar, IndexedStack, BottomNav, Toast overlay
│   │
│   ├── convert/
│   │   ├── convert_controller.dart    # Swap animation, sparkline data, save-to-ledger
│   │   └── convert_view.dart          # Calculator keypad, currency selectors, result display
│   │
│   ├── history/
│   │   ├── history_controller.dart    # Chart data loading, range selection (7/30/90/365d), stats
│   │   └── history_view.dart          # fl_chart area chart, stat cards, rate table
│   │
│   ├── ledger/
│   │   ├── ledger_controller.dart     # Entries list, search/filter, group-by-date, reuse
│   │   └── ledger_view.dart           # Grouped list with search bar, swipe actions
│   │
│   └── settings/
│       ├── settings_controller.dart   # Source selection, sync interval, cache toggle persistence
│       └── settings_view.dart         # Source cards with status badges, preference switches
│
└── widgets/                           # Shared, reusable UI components
    ├── animated_number.dart           # Smoothly animating numeric display
    ├── api_error_sheet.dart           # Bottom sheet for API error details + retry/cache actions
    ├── area_chart_widget.dart         # Configurable fl_chart wrapper with touch tooltips
    ├── badge_chip.dart                # PulseDot + status badge (Live/Cached/Offline)
    ├── currency_picker_sheet.dart     # Modal bottom sheet with search + popular-currencies grid
    ├── currency_token.dart            # Circular avatar with flag + hue-colored background
    ├── glass_card.dart                # Glassmorphism container (frosted blur + border)
    ├── no_internet_view.dart          # Full-screen offline placeholder with retry
    ├── offline_banner.dart            # Slim top banner for degraded connectivity
    └── sparkline_painter.dart         # Custom painter for mini sparkline in ConvertView
```

---

## App Flow

### 1. Startup Sequence

```
main()
 ├─ WidgetsFlutterBinding.ensureInitialized()
 ├─ Lock orientation to portrait
 ├─ Set transparent system bars (edge-to-edge)
 ├─ CacheService.instance.init()          ← SharedPreferences ready
 └─ runApp(VistaForexApp)
      └─ GetMaterialApp
           ├─ initialBinding: HomeBinding()
           │    ├─ lazyPut HomeController     ← fetches rates on init
           │    ├─ lazyPut ConvertController
           │    ├─ lazyPut HistoryController
           │    ├─ lazyPut LedgerController
           │    └─ lazyPut SettingsController
           └─ home: HomeView()
```

### 2. HomeController Initialization

When the `HomeController` is first accessed:

1. **DioClient** is initialized (configures Dio with timeouts + interceptors).
2. **ConnectivityService** is registered as a `GetxService` and begins monitoring network status.
3. A **listener** is set on `ConnectivityService.isOnline` to transition the `connState` between `live ↔ cached` and auto-refetch when coming back online.
4. **`fetchRates()`** is called, triggering the first data load through `ExchangeRateRepository`.

### 3. Screen Navigation

The app uses an **`IndexedStack`** inside `HomeView` to keep all four screens alive simultaneously:

```
 BottomNav (tab index) ──→ HomeController.currentTab (Rx<int>)
                              │
                    ┌─────────┼─────────┬──────────┐
                    ▼         ▼         ▼          ▼
              ConvertView  HistoryView  LedgerView  SettingsView
                (0)          (1)         (2)          (3)
```

- **Tab 0 — Convert**: Currency pair selector → keypad input → live result with sparkline
- **Tab 1 — History**: Area chart with range pills (7d/30d/90d/1y) → stats cards (hi/lo/avg/vol)
- **Tab 2 — Ledger**: Chronologically grouped list of saved conversions → tap to reuse
- **Tab 3 — Settings**: API source selector → sync interval → cache toggle → about

### 4. Conversion Flow

```
User taps currency token
  → CurrencyPickerSheet opens (modal bottom sheet)
  → User selects new currency
  → homeController.fromCode / toCode updates (Rx)
  → crossRate recomputes automatically (getter)
  → ConvertView result display rebuilds (Obx)
  → ConvertController._loadSpark() fires (ever() worker)
  → 30-day sparkline refreshes

User taps keypad digits
  → homeController.amount updates (Rx)
  → result = amount × crossRate (reactive getter)
  → AnimatedNumber widget interpolates to new value

User taps "Save"
  → ConvertController.save()
  → HomeController.saveConversion()
  → LedgerRepository.record() → SharedPreferences
  → Toast: "Saved to your ledger"
```

### 5. Rate Fetching & Caching Flow

```
HomeController.fetchRates()
  │
  ▼
ExchangeRateRepository.getRates(base: 'USD', sourceId)
  │
  ├── TRY: _fetchFromSource(sourceId)
  │     ├── 'frankfurter' → FrankfurterProvider.fetchLatest()  ── GET api.frankfurter.app/latest
  │     └── 'open_er'     → OpenErProvider.fetchLatest()       ── GET open.er-api.com/v6/latest/USD
  │     │
  │     └── Success → _cacheRates() → SharedPreferences
  │                   return RatesResult(fromCache: false)
  │
  ├── CATCH DioException:
  │     └── _loadCachedRates() from SharedPreferences
  │         ├── Found → return RatesResult(fromCache: true)
  │         └── null  → throw
  │
  └── CATCH any:
        └── _loadCachedRates()
            ├── Found → return cached
            └── null  → return kFallbackRates (hardcoded)
```

### 6. Connectivity State Machine

```
        ┌──────────────┐
        │  ConnState    │
        │    .live      │ ◄── Successful network fetch
        └──────┬───────┘
               │ Network drops (ConnectivityService.isOnline → false)
               ▼
        ┌──────────────┐
        │  ConnState    │
        │   .cached     │ ◄── Using SharedPreferences data
        └──────┬───────┘
               │ Fetch fails + no cache available
               ▼
        ┌──────────────┐
        │  ConnState    │
        │   .offline    │ ◄── Error state, retry available
        └──────────────┘

Visual indicator in AppBar:
  • Live    → green PulseDot + "Live"
  • Cached  → amber storage icon + "Cached"
  • Offline → red wifi-off icon + "Offline"
```

---

## State Management

### GetX Reactive (`.obs` + `Obx`)

All state management uses **GetX reactive observables**. There is no use of `StatefulWidget` except for animation controllers. The pattern:

```dart
// In Controller (ViewModel)
final amount = 1000.0.obs;           // Observable primitive
final rates = <String, double>{}.obs; // Observable map
final connState = ConnState.live.obs;  // Observable enum

// In View
Obx(() => Text('${controller.amount.value}'));  // Auto-rebuilds on change
```

### Controller Hierarchy

| Controller | Scope | Owns | Reads From |
|---|---|---|---|
| `HomeController` | Global (shell) | `fromCode`, `toCode`, `amount`, `rates`, `connState`, `currentTab`, `isDark` | `ExchangeRateRepository`, `ConnectivityService` |
| `ConvertController` | Convert tab | `swapAngle`, `isSaved`, `spark` (30-day) | `HomeController` (pair, rates) |
| `HistoryController` | History tab | `selectedDays`, `historyPoints`, `isLoading` | `HomeController` (pair, rates) |
| `LedgerController` | Ledger tab | `entries`, `searchQuery` | `HomeController` (tab index), `LedgerRepository` |
| `SettingsController` | Settings tab | `activeSourceId`, `syncInterval`, `useOfflineCache` | `HomeController` (source), `CacheService` |

### Reactive Workers (`ever`)

Side-effects are wired using GetX `ever()` workers to avoid manual listener management:

```dart
// ConvertController — reload sparkline when the currency pair changes
ever(home.fromCode, (_) => _loadSpark());
ever(home.toCode,   (_) => _loadSpark());
ever(home.rates,    (_) => _loadSpark());

// HistoryController — reload chart when range or pair changes
ever(selectedDays,  (_) => loadHistory());
ever(home.fromCode, (_) => loadHistory());
ever(home.toCode,   (_) => loadHistory());

// LedgerController — reload entries when switching to ledger tab
ever(home.currentTab, (tab) { if (tab == 2) loadEntries(); });
```

### Dependency Injection

All controllers are registered via `HomeBinding` using **`Get.lazyPut`** with `fenix: true` (auto-recreate if disposed):

```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(HomeController.new, fenix: true);
    Get.lazyPut<ConvertController>(ConvertController.new, fenix: true);
    Get.lazyPut<HistoryController>(HistoryController.new, fenix: true);
    Get.lazyPut<LedgerController>(LedgerController.new, fenix: true);
    Get.lazyPut<SettingsController>(SettingsController.new, fenix: true);
  }
}
```

Feature controllers access shared state via `Get.find<HomeController>()`:
```dart
class ConvertController extends GetxController {
  HomeController get home => Get.find<HomeController>();
}
```

---

## Data Layer

### Models (`data/models.dart`)

| Model | Purpose |
|---|---|
| `Currency` | Static metadata: `code`, `name`, `symbol`, `flag` emoji, `hue` for avatar color |
| `RatePoint` | Single data point: `date` + `value` (used in history charts) |
| `ConversionEntry` | Ledger record: pair, amount, rate, timestamp, source name (JSON serializable) |
| `ApiSource` | API provider metadata: id, name, description, frequency, status, latency |
| `RatesResult` | Network/cache response wrapper: rates map + base + date + `fromCache` flag |
| `HistoryResult` | Time-series response wrapper: `List<RatePoint>` + `fromCache` flag |

### Repositories

| Repository | Storage | Role |
|---|---|---|
| `ExchangeRateRepository` | Network + `CacheService` | Orchestrates rate fetching with multi-tier fallback (API → cache → hardcoded). Supports both latest rates and historical time-series. |
| `LedgerRepository` | `CacheService` | CRUD for conversion history entries. JSON-serialized list in SharedPreferences. |

### API Providers

| Provider | API | Capabilities |
|---|---|---|
| `FrankfurterProvider` | `api.frankfurter.app` | Latest rates (33 currencies) + historical time-series. Free, no API key. |
| `OpenErProvider` | `open.er-api.com` | Latest rates (160+ currencies). Free tier, no API key. |

### Caching Strategy

- **Rates**: Stored as JSON in SharedPreferences under `cached_rates` with a `cached_rates_ts` timestamp.
- **History**: Keyed per pair+range (`cached_history_{FROM}_{TO}_{DAYS}`).
- **Ledger**: Stored as a JSON array under `conversion_ledger`.
- **Settings**: Individual keys (`active_source`, `sync_interval`, `use_offline_cache`).

---

## Theming & Design System

### Dual Palette (`app/colors.dart`)

The app defines a complete **light** and **dark** palette as top-level constants (e.g., `kLightBg`, `kDarkBg`), unified through the `VfColors` helper class:

```dart
final c = VfColors(dark: controller.isDark.value);
// c.bg, c.surface, c.glass, c.text, c.accentSoft, c.up, c.down, ...
```

### Glassmorphism

- **AppBar**: `BackdropFilter(blur: 14)` + semi-transparent `glass` fill + 1px border
- **BottomNav**: `BackdropFilter(blur: 18)` + `glass` fill + top border
- **GlassCard**: Reusable widget combining blur, tint, and border for card containers

### Material 3

`AppTheme._build()` constructs a `ThemeData` with:
- Custom `ColorScheme` from the `VfColors` palette
- Transparent app bar and bottom nav backgrounds
- `NoSplash.splashFactory` for a clean, non-ripple tap feel
- `Helvetica Neue` as the default font family

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.12.1`
- Dart SDK (bundled with Flutter)

### Install & Run

```bash
# Clone
git clone https://github.com/<your-org>/vistaforex-mobile-app.git
cd vistaforex-mobile-app

# Install dependencies
flutter pub get

# Run in debug mode
flutter run
```

### Build for Release

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

---

<p align="center">
  Built with ❤️ using Flutter & GetX
</p>
