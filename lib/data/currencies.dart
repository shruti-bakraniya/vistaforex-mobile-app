import 'models.dart';

const kCurrencies = <Currency>[
  Currency(code: 'USD', name: 'US Dollar',          symbol: r'$',  flag: '🇺🇸', hue: 145),
  Currency(code: 'INR', name: 'Indian Rupee',        symbol: '₹',   flag: '🇮🇳', hue: 28),
  Currency(code: 'EUR', name: 'Euro',                symbol: '€',   flag: '🇪🇺', hue: 230),
  Currency(code: 'GBP', name: 'British Pound',       symbol: '£',   flag: '🇬🇧', hue: 268),
  Currency(code: 'JPY', name: 'Japanese Yen',        symbol: '¥',   flag: '🇯🇵', hue: 350),
  Currency(code: 'CAD', name: 'Canadian Dollar',     symbol: 'C\$', flag: '🇨🇦', hue: 8),
  Currency(code: 'AUD', name: 'Australian Dollar',   symbol: 'A\$', flag: '🇦🇺', hue: 200),
  Currency(code: 'CHF', name: 'Swiss Franc',         symbol: 'Fr',  flag: '🇨🇭', hue: 5),
  Currency(code: 'CNY', name: 'Chinese Yuan',        symbol: '¥',   flag: '🇨🇳', hue: 12),
  Currency(code: 'SGD', name: 'Singapore Dollar',    symbol: 'S\$', flag: '🇸🇬', hue: 0),
  Currency(code: 'AED', name: 'UAE Dirham',          symbol: 'د.إ', flag: '🇦🇪', hue: 130),
  Currency(code: 'HKD', name: 'Hong Kong Dollar',    symbol: 'HK\$',flag: '🇭🇰', hue: 350),
  Currency(code: 'NZD', name: 'New Zealand Dollar',  symbol: 'NZ\$',flag: '🇳🇿', hue: 210),
  Currency(code: 'SEK', name: 'Swedish Krona',       symbol: 'kr',  flag: '🇸🇪', hue: 220),
  Currency(code: 'ZAR', name: 'South African Rand',  symbol: 'R',   flag: '🇿🇦', hue: 100),
  Currency(code: 'BRL', name: 'Brazilian Real',      symbol: 'R\$', flag: '🇧🇷', hue: 140),
  Currency(code: 'MXN', name: 'Mexican Peso',        symbol: 'Mex\$',flag:'🇲🇽', hue: 150),
  Currency(code: 'KRW', name: 'South Korean Won',    symbol: '₩',   flag: '🇰🇷', hue: 235),
];

const kPopularCurrencies = ['USD', 'EUR', 'GBP', 'INR', 'JPY', 'AUD'];

final kCurrencyMap = {for (final c in kCurrencies) c.code: c};

Currency getCurrency(String code) =>
    kCurrencyMap[code] ?? kCurrencies.first;

/// Fallback exchange rates per 1 USD (used when API is unavailable and no cache exists).
const kFallbackRates = <String, double>{
  'USD': 1.0,
  'INR': 83.42,
  'EUR': 0.9187,
  'GBP': 0.7843,
  'JPY': 156.82,
  'CAD': 1.3662,
  'AUD': 1.5121,
  'CHF': 0.8823,
  'CNY': 7.2455,
  'SGD': 1.3486,
  'AED': 3.6725,
  'HKD': 7.8102,
  'NZD': 1.6354,
  'SEK': 10.612,
  'ZAR': 18.214,
  'BRL': 5.0931,
  'MXN': 17.045,
  'KRW': 1372.4,
};
