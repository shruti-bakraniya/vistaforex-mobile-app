import 'package:flutter/material.dart';
import '../app/colors.dart';

enum BadgeTone { neutral, accent, up, down, warn }

class BadgeChip extends StatelessWidget {
  const BadgeChip({
    super.key,
    required this.label,
    this.tone = BadgeTone.neutral,
    this.leading,
    this.fontSize = 11.5,
    this.padding,
  });

  final String label;
  final BadgeTone tone;
  final Widget? leading;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = VfColors(dark: dark);

    final (bg, fg) = switch (tone) {
      BadgeTone.neutral => (c.surface2, c.text2),
      BadgeTone.accent => (c.accentSoft, c.accentText),
      BadgeTone.up => (c.upSoft, c.up),
      BadgeTone.down => (c.downSoft, c.down),
      BadgeTone.warn => (c.warnSoft, c.warn),
    };

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.01,
            ),
          ),
        ],
      ),
    );
  }
}

class PulseDot extends StatefulWidget {
  const PulseDot({super.key, required this.color});
  final Color color;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1.0, end: 0.35).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
