import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/colors.dart';
import '../../widgets/badge_chip.dart';
import '../convert/convert_view.dart';
import '../history/history_view.dart';
import '../ledger/ledger_view.dart';
import '../settings/settings_view.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = controller.isDark.value;
      final c = VfColors(dark: dark);

      return Theme(
        data: dark ? _darkTheme() : _lightTheme(),
        child: Scaffold(
          backgroundColor: c.bg,
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: _AppBar(c: c, dark: dark),
          body: Stack(
            children: [
              // Background gradient
              Positioned.fill(
                child: _BgGradient(dark: dark),
              ),
              // Screen content
              Padding(
                padding: EdgeInsets.only(
                  top: kToolbarHeight + MediaQuery.of(context).padding.top,
                ),
                child: IndexedStack(
                  index: controller.currentTab.value,
                  children: const [
                    ConvertView(),
                    HistoryView(),
                    LedgerView(),
                    SettingsView(),
                  ],
                ),
              ),
              // Toast
              Obx(() {
                final msg = controller.toastMessage.value;
                if (msg == null) return const SizedBox.shrink();
                return _Toast(message: msg, c: c);
              }),
            ],
          ),
          bottomNavigationBar: _BottomNav(c: c),
        ),
      );
    });
  }

  ThemeData _lightTheme() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: kAccent,
          secondary: kAccent,
        ),
      );

  ThemeData _darkTheme() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: kAccent,
          secondary: kAccent,
        ),
      );
}

class _BgGradient extends StatelessWidget {
  const _BgGradient({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        child: Container(
          color: dark ? kDarkBg : kLightBg,
        ),
      ),
      Positioned(
        top: -60,
        right: -80,
        child: Container(
          width: 400,
          height: 350,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                kAccent.withOpacity(dark ? 0.16 : 0.10),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -80,
        left: -100,
        child: Container(
          width: 350,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                kAccent.withOpacity(dark ? 0.08 : 0.05),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({required this.c, required this.dark});
  final VfColors c;
  final bool dark;

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: c.glass,
            border: Border(bottom: BorderSide(color: c.border, width: 1)),
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
          ),
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(children: [
              // Logo
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: kAccent.withOpacity(0.34),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.currency_exchange_rounded,
                    color: Colors.white, size: 19),
              ),
              const SizedBox(width: 11),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: c.text,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.02,
                  ),
                  children: [
                    const TextSpan(text: 'Vista'),
                    TextSpan(
                      text: 'Forex',
                      style: TextStyle(color: c.accentText),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Connectivity chip
              Obx(() {
                final state = ctrl.connState.value;
                return GestureDetector(
                  onTap: () {
                    if (state == ConnState.offline || state == ConnState.cached) {
                      ctrl.fetchRates();
                    }
                  },
                  child: Container(
                    height: 32,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11),
                    decoration: BoxDecoration(
                      color: c.surface2,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: c.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state == ConnState.live) ...[
                          PulseDot(color: c.up),
                          const SizedBox(width: 6),
                          Text(
                            'Live',
                            style: TextStyle(
                              color: c.up,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ] else if (state == ConnState.cached) ...[
                          Icon(Icons.storage_rounded,
                              color: c.warn, size: 13),
                          const SizedBox(width: 6),
                          Text(
                            'Cached',
                            style: TextStyle(
                              color: c.warn,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ] else ...[
                          Icon(Icons.wifi_off_rounded,
                              color: c.down, size: 13),
                          const SizedBox(width: 6),
                          Text(
                            'Offline',
                            style: TextStyle(
                              color: c.down,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(width: 10),
              // Theme toggle
              GestureDetector(
                onTap: ctrl.toggleTheme,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c.surface2,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: c.border),
                  ),
                  child: Icon(
                    dark ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                    color: c.text2,
                    size: 16,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.c});
  final VfColors c;

  static const _tabs = [
    (icon: Icons.currency_exchange_rounded, label: 'Convert'),
    (icon: Icons.show_chart_rounded, label: 'History'),
    (icon: Icons.receipt_long_rounded, label: 'Ledger'),
    (icon: Icons.settings_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: c.glass,
            border: Border(top: BorderSide(color: c.border, width: 1)),
          ),
          padding: EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: MediaQuery.of(context).padding.bottom + 8,
            top: 8,
          ),
          child: Obx(
            () => Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final active = ctrl.currentTab.value == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ctrl.currentTab.value = i,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 56,
                          height: 30,
                          decoration: BoxDecoration(
                            color: active ? c.accentSoft : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Icon(
                            tab.icon,
                            size: 21,
                            color: active ? c.accentText : c.text3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          style: TextStyle(
                            color: active ? c.text : c.text3,
                            fontSize: 11,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.w500,
                            letterSpacing: -0.01,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _Toast extends StatelessWidget {
  const _Toast({required this.message, required this.c});
  final String message;
  final VfColors c;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: kBottomNavigationBarHeight + 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 11),
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: c.text,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded, color: kAccent, size: 15),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    color: c.bg,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
