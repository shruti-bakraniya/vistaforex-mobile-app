class Currency {
  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
    required this.hue,
  });
  final String code;
  final String name;
  final String symbol;
  final String flag;
  final int hue; // HSL hue for the token circle color
}

class RatePoint {
  const RatePoint({required this.date, required this.value});
  final DateTime date;
  final double value;

  factory RatePoint.fromJson(MapEntry<String, dynamic> entry) {
    return RatePoint(
      date: DateTime.parse(entry.key),
      value: (entry.value as num).toDouble(),
    );
  }
}

class ConversionEntry {
  ConversionEntry({
    required this.id,
    required this.from,
    required this.to,
    required this.amount,
    required this.rate,
    required this.timestamp,
    required this.sourceName,
  });

  final String id;
  final String from;
  final String to;
  final double amount;
  final double rate;
  final DateTime timestamp;
  final String sourceName;

  double get result => amount * rate;

  Map<String, dynamic> toJson() => {
        'id': id,
        'from': from,
        'to': to,
        'amount': amount,
        'rate': rate,
        'timestamp': timestamp.toIso8601String(),
        'sourceName': sourceName,
      };

  factory ConversionEntry.fromJson(Map<String, dynamic> j) => ConversionEntry(
        id: j['id'] as String,
        from: j['from'] as String,
        to: j['to'] as String,
        amount: (j['amount'] as num).toDouble(),
        rate: (j['rate'] as num).toDouble(),
        timestamp: DateTime.parse(j['timestamp'] as String),
        sourceName: j['sourceName'] as String,
      );
}

class ApiSource {
  const ApiSource({
    required this.id,
    required this.name,
    required this.description,
    required this.frequency,
    required this.status,
    this.latencyMs,
    this.badge,
  });
  final String id;
  final String name;
  final String description;
  final String frequency;
  final ApiSourceStatus status;
  final int? latencyMs;
  final String? badge;
}

enum ApiSourceStatus { active, ok, degraded, error }

class RatesResult {
  const RatesResult({
    required this.rates,
    required this.base,
    required this.date,
    required this.fromCache,
  });
  final Map<String, double> rates;
  final String base;
  final DateTime date;
  final bool fromCache;
}

class HistoryResult {
  const HistoryResult({
    required this.points,
    required this.fromCache,
  });
  final List<RatePoint> points;
  final bool fromCache;
}
