import 'package:flutter/material.dart';
import '../data/currencies.dart';
import '../data/models.dart';

class CurrencyToken extends StatelessWidget {
  const CurrencyToken({super.key, required this.code, this.size = 40});
  final String code;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final currency = getCurrency(code);
    return _TokenCircle(currency: currency, size: size, dark: dark);
  }
}

class _TokenCircle extends StatelessWidget {
  const _TokenCircle({
    required this.currency,
    required this.size,
    required this.dark,
  });
  final Currency currency;
  final double size;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    // Derive background/foreground from currency hue
    final hue = currency.hue.toDouble();
    final bg = dark
        ? HSLColor.fromAHSL(1, hue, 0.35, 0.25).toColor()
        : HSLColor.fromAHSL(1, hue, 0.40, 0.90).toColor();
    final fg = dark
        ? HSLColor.fromAHSL(1, hue, 0.55, 0.78).toColor()
        : HSLColor.fromAHSL(1, hue, 0.55, 0.40).toColor();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        currency.symbol,
        style: TextStyle(
          color: fg,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}
