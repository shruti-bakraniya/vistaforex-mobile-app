import 'dart:ui';
import 'package:flutter/material.dart';
import '../app/colors.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.glass = true,
    this.style,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool glass;
  final BoxDecoration? style;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = VfColors(dark: dark);

    final decoration = style ??
        BoxDecoration(
          color: glass ? c.glass : c.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: glass ? c.glassBrd : c.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: dark
                  ? Colors.black.withOpacity(0.4)
                  : const Color(0xFF1C1813).withOpacity(0.07),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        );

    if (glass) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: decoration,
            padding: padding,
            child: child,
          ),
        ),
      );
    }

    return Container(
      decoration: decoration,
      padding: padding,
      child: child,
    );
  }
}
