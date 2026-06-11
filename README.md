# VistaForex

[Download Android APK](https://github.com/shruti-bakraniya/vistaforex-mobile-app/releases/download/v0.0.1/vistaforex_v1.apk)

A premium-fintech **Flutter currency converter** with a glassmorphism UI, real-time
exchange rates, offline caching, and interactive rate-history charts.

Built with **MVVM architecture** and **GetX** for state management.

<p align="center">
  <em>USD → INR · live mid-market rates · #F28500 accent</em>
</p>

## Features

- **Convert** — pick source/target currencies, enter an amount, get a live count-up result with a swap animation and quick-amount chips.
- **Rate History** — smooth area-gradient chart (`fl_chart`) with a touch crosshair, 7D/30D/90D/1Y ranges, hi/lo/avg/volatility stats, and a daily-values table.
- **Ledger** — saved conversions, date-grouped and searchable, tap to replay.
- **Settings** — choose between multiple exchange-rate data sources, set the auto-refresh interval, toggle offline caching and dark mode.
- **Glassmorphism + custom gradients** — frosted `BackdropFilter` cards over a warm-neutral canvas with an orange radial glow.
- **Robust error handling** — Dio interceptors for connectivity, timeouts, and HTTP errors; offline banner, no-internet takeover, and an API-feed error sheet.
- **Offline-first caching** — every fetch is cached to `SharedPreferences`, so conversions keep working without a connection.

## Architecture (MVVM + GetX)

```
lib/
├── main.dart                 # Entry point
├── app/                      # GetMaterialApp, colors, theme
├── core/                     # Dio client + interceptors, connectivity, cache
├── data/                     # Models, repositories, API providers
├── features/                 # convert / history / ledger / settings  (Controller + View pairs)
│   └── home/                 # Shell: app bar, bottom nav, shared HomeController
└── widgets/                  # Glass card, charts, pickers, badges, state views
```

Each screen is a **View** (UI only) bound to a GetX **Controller** (the ViewModel
holding state and logic). Repositories in `data/` are the **Model** layer — they own
networking (via Dio) and persistence (via SharedPreferences).

## Data sources

| Source | API | Key required |
|--------|-----|-------------|
| Frankfurter (ECB) | `api.frankfurter.app` | No — free |
| Open Exchange Rates | `open.er-api.com` | No — free tier |

Switchable in **Settings**; the repository falls back to cached, then seeded, rates on failure.

## Dependencies (pub.dev verified publishers only)

| Package | Publisher | Purpose |
|---------|-----------|---------|
| `get` | jonataslaw.dev | State management & navigation |
| `dio` | fluttercommunity.dev | HTTP client with interceptors |
| `fl_chart` | imaNNeo.dev | Area chart + sparkline |
| `shared_preferences` | flutter.dev | Offline caching |
| `connectivity_plus` | fluttercommunity.dev | Network detection |
| `intl` | dart.dev | Number & date formatting |
