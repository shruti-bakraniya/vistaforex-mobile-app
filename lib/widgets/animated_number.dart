import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimatedNumber extends StatefulWidget {
  const AnimatedNumber({
    super.key,
    required this.value,
    required this.decimalPlaces,
    this.style,
    this.prefix = '',
  });

  final double value;
  final int decimalPlaces;
  final TextStyle? style;
  final String prefix;

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  double _from = 0;

  @override
  void initState() {
    super.initState();
    _from = widget.value;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _anim = Tween<double>(begin: widget.value, end: widget.value)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(AnimatedNumber old) {
    super.didUpdateWidget(old);
    if ((old.value - widget.value).abs() > 1e-9) {
      _from = old.value;
      _anim = Tween<double>(begin: _from, end: widget.value)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final formatted = NumberFormat.decimalPatternDigits(
          decimalDigits: widget.decimalPlaces,
        ).format(_anim.value);
        return Text(
          '${widget.prefix}$formatted',
          style: widget.style,
        );
      },
    );
  }
}

String fmtRate(double n) {
  if (!n.isFinite) return '—';
  final dp = n >= 100 ? 2 : n >= 1 ? 4 : 6;
  return NumberFormat.decimalPatternDigits(decimalDigits: dp).format(n);
}

String fmtMoney(double n, int dp) {
  if (!n.isFinite) return '—';
  return NumberFormat.decimalPatternDigits(decimalDigits: dp).format(n);
}
