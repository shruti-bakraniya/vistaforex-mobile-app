import 'package:flutter/material.dart';

const kAccent = Color(0xFFF28500);

// ── Light palette ──────────────────────────────────────────────
const kLightBg = Color(0xFFF7F4EF);
const kLightSurface = Color(0xFFFFFFFF);
const kLightSurface2 = Color(0xFFF3EFE8);
const kLightSurface3 = Color(0xFFEBE6DD);
const kLightGlass = Color(0xB8FFFFFF);
const kLightGlassBrd = Color(0xB2FFFFFF);
const kLightText = Color(0xFF1C1813);
const kLightText2 = Color(0xFF6E665B);
const kLightText3 = Color(0xFFA39A8C);
const kLightBorder = Color(0x171C1813);
const kLightBorder2 = Color(0x291C1813);
const kLightAccentSoft = Color(0x1FF28500);
const kLightAccentText = Color(0xFFC25E00);
const kLightUp = Color(0xFF1E9E6A);
const kLightUpSoft = Color(0x1F1E9E6A);
const kLightDown = Color(0xFFDC4B4B);
const kLightDownSoft = Color(0x1FDC4B4B);
const kLightWarn = Color(0xFFD98A00);
const kLightWarnSoft = Color(0x21D98A00);

// ── Dark palette ───────────────────────────────────────────────
const kDarkBg = Color(0xFF14110D);
const kDarkSurface = Color(0xFF1E1A15);
const kDarkSurface2 = Color(0xFF241F19);
const kDarkSurface3 = Color(0xFF2B251E);
const kDarkGlass = Color(0xB81E1A15);
const kDarkGlassBrd = Color(0x14FFFFFF);
const kDarkText = Color(0xFFF4EFE7);
const kDarkText2 = Color(0xFFA79E90);
const kDarkText3 = Color(0xFF6E665A);
const kDarkBorder = Color(0x14FFFFFF);
const kDarkBorder2 = Color(0x26FFFFFF);
const kDarkAccentSoft = Color(0x29F28500);
const kDarkAccentText = Color(0xFFFF9D2E);
const kDarkUp = Color(0xFF38C98A);
const kDarkUpSoft = Color(0x2638C98A);
const kDarkDown = Color(0xFFFF6B6B);
const kDarkDownSoft = Color(0x26FF6B6B);
const kDarkWarn = Color(0xFFFFB23E);
const kDarkWarnSoft = Color(0x26FFB23E);

/// Provides all semantic colors from dark/light mode context.
class VfColors {
  const VfColors({required this.dark});
  final bool dark;

  Color get bg => dark ? kDarkBg : kLightBg;
  Color get surface => dark ? kDarkSurface : kLightSurface;
  Color get surface2 => dark ? kDarkSurface2 : kLightSurface2;
  Color get surface3 => dark ? kDarkSurface3 : kLightSurface3;
  Color get glass => dark ? kDarkGlass : kLightGlass;
  Color get glassBrd => dark ? kDarkGlassBrd : kLightGlassBrd;
  Color get text => dark ? kDarkText : kLightText;
  Color get text2 => dark ? kDarkText2 : kLightText2;
  Color get text3 => dark ? kDarkText3 : kLightText3;
  Color get border => dark ? kDarkBorder : kLightBorder;
  Color get border2 => dark ? kDarkBorder2 : kLightBorder2;
  Color get accentSoft => dark ? kDarkAccentSoft : kLightAccentSoft;
  Color get accentText => dark ? kDarkAccentText : kLightAccentText;
  Color get up => dark ? kDarkUp : kLightUp;
  Color get upSoft => dark ? kDarkUpSoft : kLightUpSoft;
  Color get down => dark ? kDarkDown : kLightDown;
  Color get downSoft => dark ? kDarkDownSoft : kLightDownSoft;
  Color get warn => dark ? kDarkWarn : kLightWarn;
  Color get warnSoft => dark ? kDarkWarnSoft : kLightWarnSoft;

  // Gradient overlays applied to the background
  List<Color> get bgGradColors => dark
      ? [
          const Color(0xFFF28500).withOpacity(0.16),
          Colors.transparent,
          const Color(0xFFF28500).withOpacity(0.08),
          Colors.transparent,
        ]
      : [
          const Color(0xFFF28500).withOpacity(0.10),
          Colors.transparent,
          const Color(0xFFF28500).withOpacity(0.05),
          Colors.transparent,
        ];
}
