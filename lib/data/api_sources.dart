import 'models.dart';

const kApiSources = <ApiSource>[
  ApiSource(
    id: 'frankfurter',
    name: 'Frankfurter (ECB)',
    description: 'European Central Bank official daily rates · 33 currencies',
    frequency: 'Daily · 16:00 CET',
    status: ApiSourceStatus.active,
    latencyMs: 90,
    badge: 'Free',
  ),
  ApiSource(
    id: 'open_er',
    name: 'Open Exchange Rates',
    description: 'Broad coverage · 160+ currency pairs · hourly updates',
    frequency: 'Hourly',
    status: ApiSourceStatus.ok,
    latencyMs: 130,
  ),
  ApiSource(
    id: 'fixer',
    name: 'Fixer.io',
    description: 'Legacy bank feed · requires API key in settings',
    frequency: 'Real-time · 60s',
    status: ApiSourceStatus.degraded,
    latencyMs: 260,
  ),
  ApiSource(
    id: 'exchangerate_api',
    name: 'ExchangeRate-API',
    description: 'First-party aggregated feed · 38 venues · requires key',
    frequency: 'Real-time · 5s',
    status: ApiSourceStatus.ok,
    latencyMs: 42,
    badge: 'Premium',
  ),
  ApiSource(
    id: 'cryptobridge',
    name: 'CryptoBridge FX',
    description: 'Community relay · unverified data source',
    frequency: 'Real-time · 10s',
    status: ApiSourceStatus.error,
  ),
];
