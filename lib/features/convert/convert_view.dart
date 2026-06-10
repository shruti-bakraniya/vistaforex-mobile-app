import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/colors.dart';
import '../../data/currencies.dart';
import '../../widgets/animated_number.dart';
import '../../widgets/badge_chip.dart';
import '../../widgets/currency_picker_sheet.dart';
import '../../widgets/currency_token.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/no_internet_view.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/sparkline_painter.dart';
import '../home/home_controller.dart';
import 'convert_controller.dart';

class ConvertView extends GetView<ConvertController> {
  const ConvertView({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();

    return Obx(() {
      final dark = home.isDark.value;
      final c = VfColors(dark: dark);

      if (home.connState.value == ConnState.offline) {
        return NoInternetView(
          onRetry: home.retryConnection,
          onUseCache: home.useCachedRates,
          lastSyncTime: home.lastSyncTime,
        );
      }

      return RefreshIndicator(
        onRefresh: home.fetchRates,
        color: kAccent,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
          children: [
            if (home.connState.value == ConnState.cached)
              OfflineBanner(
                lastSyncTime: home.lastSyncTime,
                onRetry: home.fetchRates,
              ),
            _Header(home: home, c: c),
            const SizedBox(height: 16),
            _ConverterCard(c: c, dark: dark),
            const SizedBox(height: 14),
            _ActionRow(c: c),
            const SizedBox(height: 12),
            _MiniStatsGrid(c: c),
          ],
        ),
      );
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.home, required this.c});
  final HomeController home;
  final VfColors c;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Convert',
                style: TextStyle(
                  color: c.text,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.025,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Live mid-market rates, no hidden spread.',
                style: TextStyle(
                  color: c.text2,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          final isLive = home.connState.value == ConnState.live;
          return BadgeChip(
            label: isLive ? 'Live' : 'Cached',
            tone: isLive ? BadgeTone.up : BadgeTone.warn,
            leading: isLive
                ? PulseDot(color: c.up)
                : Icon(Icons.storage_rounded, color: c.warn, size: 12),
          );
        }),
      ],
    );
  }
}

class _ConverterCard extends GetView<ConvertController> {
  const _ConverterCard({required this.c, required this.dark});
  final VfColors c;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();

    return GlassCard(
      padding: EdgeInsets.zero,
      glass: true,
      borderRadius: 20,
      child: Column(children: [
        // FROM section
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => _CurrencyPill(
                label: 'You send',
                code: home.fromCode.value,
                onTap: () => _pickCurrency(context, 'from', home),
                c: c,
              ),),
              const SizedBox(height: 16),
              Obx(() => _AmountInput(
                    symbol: home.fromCurrency.symbol,
                    amount: home.amount.value,
                    onChanged: (v) => home.amount.value = v,
                    c: c,
                  )),
              const SizedBox(height: 14),
              Obx(() => _QuickChips(
                    amount: home.amount.value,
                    onSelect: (v) => home.amount.value = v,
                    c: c,
                  )),
            ],
          ),
        ),

        // Divider with swap FAB
        Obx(() => _SwapDivider(angle: controller.swapAngle.value, c: c)),

        // TO section
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => _CurrencyPill(
                    label: 'They receive',
                    code: home.toCode.value,
                    onTap: () => _pickCurrency(context, 'to', home),
                    c: c,
                  )),
              const SizedBox(height: 16),
              Obx(() {
                final toCur = home.toCurrency;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      toCur.symbol,
                      style: TextStyle(
                        color: c.text3,
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedNumber(
                      value: home.result,
                      decimalPlaces: 2,
                      style: TextStyle(
                        color: c.accentText,
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.02,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 13),
              Text(
                'Rate guaranteed for the next 09:58',
                style: TextStyle(
                  color: c.text3,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),

        // Rate footer
        _RateFooter(c: c, home: home),
      ]),
    );
  }

  Future<void> _pickCurrency(
    BuildContext context,
    String side,
    HomeController home,
  ) async {
    final code = await showCurrencyPicker(
      context,
      side: side,
      fromCode: home.fromCode.value,
      toCode: home.toCode.value,
      rates: home.rates.value,
    );
    if (code == null) return;
    if (side == 'from') {
      if (code == home.toCode.value) home.toCode.value = home.fromCode.value;
      home.fromCode.value = code;
    } else {
      if (code == home.fromCode.value) home.fromCode.value = home.toCode.value;
      home.toCode.value = code;
    }
  }
}

class _CurrencyPill extends StatelessWidget {
  const _CurrencyPill({
    required this.label,
    required this.code,
    required this.onTap,
    required this.c,
  });
  final String label;
  final String code;
  final VoidCallback onTap;
  final VfColors c;

  @override
  Widget build(BuildContext context) {
    final cur = getCurrency(code);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: c.text3,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.06,
          ),
        ),
        const SizedBox(height: 9),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
            decoration: BoxDecoration(
              color: c.surface2,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: c.border),
            ),
            child: Row(children: [
              CurrencyToken(code: code, size: 36),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cur.code,
                      style: TextStyle(
                        color: c.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.01,
                      ),
                    ),
                    Text(
                      cur.name,
                      style: TextStyle(color: c.text2, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, color: c.text3, size: 17),
            ]),
          ),
        ),
      ],
    );
  }
}

class _AmountInput extends StatefulWidget {
  const _AmountInput({
    required this.symbol,
    required this.amount,
    required this.onChanged,
    required this.c,
  });
  final String symbol;
  final double amount;
  final ValueChanged<double> onChanged;
  final VfColors c;

  @override
  State<_AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<_AmountInput> {
  late final TextEditingController _ctrl;
  bool _userEditing = false;

  String _fmt(double v) => v == v.truncateToDouble()
      ? NumberFormat('#,##0').format(v.toInt())
      : NumberFormat('#,##0.##').format(v);

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _fmt(widget.amount));
  }

  @override
  void didUpdateWidget(_AmountInput old) {
    super.didUpdateWidget(old);
    // Sync text only when amount changed externally (quick chips / reuse)
    if (!_userEditing &&
        (old.amount - widget.amount).abs() > 0.001) {
      _ctrl.text = _fmt(widget.amount);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          widget.symbol,
          style: TextStyle(
            color: widget.c.text3,
            fontSize: 26,
            fontWeight: FontWeight.w500,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _ctrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            style: TextStyle(
              color: widget.c.text,
              fontSize: 40,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.02,
              fontFamily: 'monospace',
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onTap: () => _userEditing = true,
            onEditingComplete: () => _userEditing = false,
            onChanged: (v) {
              final parsed = double.tryParse(v.replaceAll(',', ''));
              if (parsed != null) widget.onChanged(parsed);
            },
          ),
        ),
      ],
    );
  }
}

class _QuickChips extends StatelessWidget {
  const _QuickChips({
    required this.amount,
    required this.onSelect,
    required this.c,
  });
  final double amount;
  final ValueChanged<double> onSelect;
  final VfColors c;

  static const _values = [100.0, 500.0, 1000.0, 5000.0];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      children: _values.map((v) {
        final active = amount == v;
        return GestureDetector(
          onTap: () => onSelect(v),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: active ? c.accentSoft : c.surface2,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: active ? Colors.transparent : c.border,
              ),
            ),
            child: Text(
              NumberFormat('#,##0').format(v.toInt()),
              style: TextStyle(
                color: active ? c.accentText : c.text2,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SwapDivider extends GetView<ConvertController> {
  const _SwapDivider({required this.angle, required this.c});
  final double angle;
  final VfColors c;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Divider(color: c.border, height: 1),
          Positioned(
            right: 6,
            top: -23,
            child: GestureDetector(
              onTap: controller.swap,
              child: AnimatedRotation(
                turns: angle / 360,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: kAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.surface, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: kAccent.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.swap_vert_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RateFooter extends GetView<ConvertController> {
  const _RateFooter({required this.c, required this.home});
  final VfColors c;
  final HomeController home;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sparkVals = controller.spark;
      final pct = controller.sparkPct;
      final up = controller.sparkUp;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.border, width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1 ${home.fromCode.value} = ${fmtRate(home.crossRate)} ${home.toCode.value}',
                    style: TextStyle(
                      color: c.text,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 6),
                  BadgeChip(
                    label: '${up ? '+' : ''}${pct.toStringAsFixed(2)}% · 30d',
                    tone: up ? BadgeTone.up : BadgeTone.down,
                    leading: Icon(
                      up
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: up ? c.up : c.down,
                      size: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (sparkVals.isNotEmpty)
              SparklineWidget(
                values: sparkVals.toList(),
                color: kAccent,
                width: 84,
                height: 30,
              ),
          ],
        ),
      );
    });
  }
}

class _ActionRow extends GetView<ConvertController> {
  const _ActionRow({required this.c});
  final VfColors c;

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    return Row(children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () => home.currentTab.value = 1,
          icon: const Icon(Icons.show_chart_rounded, size: 16),
          label: const Text('History'),
          style: OutlinedButton.styleFrom(
            foregroundColor: c.text,
            side: BorderSide(color: c.border2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Obx(() {
          final saved = controller.isSaved.value;
          return ElevatedButton.icon(
            onPressed: saved ? null : controller.save,
            icon: Icon(
              saved ? Icons.check_rounded : Icons.add_rounded,
              size: 16,
            ),
            label: Text(saved ? 'Saved' : 'Save conversion'),
            style: ElevatedButton.styleFrom(
              backgroundColor: saved ? c.surface2 : kAccent,
              foregroundColor: saved ? c.accentText : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 13),
              elevation: 0,
            ),
          );
        }),
      ),
    ]);
  }
}

class _MiniStatsGrid extends GetView<ConvertController> {
  const _MiniStatsGrid({required this.c});
  final VfColors c;

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    return Obx(() {
      final rate = home.crossRate;
      final from = home.fromCode.value;
      final to = home.toCode.value;
      final hasSpark = controller.spark.isNotEmpty;
      final lo = controller.sparkLo;
      final hi = controller.sparkHi;

      return Column(children: [
        Row(children: [
          Expanded(
              child: _MiniStat(
                  label: 'Mid-market',
                  value: fmtRate(rate),
                  sub: '1 $from → $to',
                  icon: Icons.bolt_rounded,
                  c: c)),
          const SizedBox(width: 10),
          Expanded(
              child: _MiniStat(
                  label: 'Inverse',
                  value: rate == 0 ? '—' : fmtRate(1 / rate),
                  sub: '1 $to → $from',
                  icon: Icons.currency_exchange_rounded,
                  c: c)),
        ]),
        const SizedBox(height: 10),
        _MiniStat(
          label: '30-day range',
          value: hasSpark ? '${fmtRate(lo)} – ${fmtRate(hi)}' : '—',
          sub: 'low – high',
          icon: Icons.show_chart_rounded,
          c: c,
        ),
      ]);
    });
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.c,
  });
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final VfColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: c.text3, size: 14),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                  color: c.text3, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ]),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: c.text,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              letterSpacing: -0.01,
            ),
          ),
          const SizedBox(height: 5),
          Text(sub,
              style: TextStyle(color: c.text3, fontSize: 11.5)),
        ],
      ),
    );
  }
}
