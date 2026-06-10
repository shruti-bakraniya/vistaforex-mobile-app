import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/colors.dart';
import '../../widgets/animated_number.dart';
import '../../widgets/area_chart_widget.dart';
import '../../widgets/badge_chip.dart';
import '../../widgets/currency_picker_sheet.dart';
import '../../widgets/currency_token.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/offline_banner.dart';
import '../home/home_controller.dart';
import 'history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();

    return Obx(() {
      final dark = home.isDark.value;
      final c = VfColors(dark: dark);

      return RefreshIndicator(
        onRefresh: controller.loadHistory,
        color: kAccent,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
          children: [
            if (home.connState.value == ConnState.cached)
              OfflineBanner(lastSyncTime: home.lastSyncTime),
            // Page header
            Text(
              'Rate history',
              style: TextStyle(
                color: c.text,
                fontSize: 26,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.025,
              ),
            ),
            const SizedBox(height: 14),
            // Pair selector
            _PairSelector(home: home, c: c),
            const SizedBox(height: 14),
            // Range selector
            _RangeSelector(controller: controller, c: c),
            const SizedBox(height: 14),
            // Chart card
            _ChartCard(controller: controller, home: home, c: c),
            const SizedBox(height: 12),
            // Stats grid 2×2
            _StatsGrid(controller: controller, c: c),
            const SizedBox(height: 12),
            // Daily values table
            _DailyTable(controller: controller, c: c),
          ],
        ),
      );
    });
  }
}

class _PairSelector extends StatelessWidget {
  const _PairSelector({required this.home, required this.c});
  final HomeController home;
  final VfColors c;

  Future<void> _pick(BuildContext ctx, String side) async {
    final code = await showCurrencyPicker(
      ctx,
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

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _PairBtn(code: home.fromCode.value, c: c, onTap: () => _pick(context, 'from'))),
      const SizedBox(width: 9),
      Icon(Icons.arrow_forward_rounded, color: c.text3, size: 17),
      const SizedBox(width: 9),
      Expanded(child: _PairBtn(code: home.toCode.value, c: c, onTap: () => _pick(context, 'to'))),
    ]);
  }
}

class _PairBtn extends StatelessWidget {
  const _PairBtn({required this.code, required this.c, required this.onTap});
  final String code;
  final VfColors c;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: c.border),
        ),
        child: Row(children: [
          CurrencyToken(code: code, size: 28),
          const SizedBox(width: 8),
          Text(
            code,
            style: TextStyle(
              color: c.text,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Icon(Icons.keyboard_arrow_down_rounded, color: c.text3, size: 14),
        ]),
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.controller, required this.c});
  final HistoryController controller;
  final VfColors c;

  static const _labels = {7: '7D', 30: '30D', 90: '90D', 365: '1Y'};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: HistoryController.rangeDays.map((d) {
          final active = controller.selectedDays.value == d;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.selectedDays.value = d,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 34,
                decoration: BoxDecoration(
                  color: active ? c.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _labels[d] ?? '$d',
                    style: TextStyle(
                      color: active ? c.text : c.text2,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.controller,
    required this.home,
    required this.c,
  });
  final HistoryController controller;
  final HomeController home;
  final VfColors c;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1 ${home.fromCode.value} = ${home.toCode.value} · ${controller.selectedDays.value}d',
                      style: TextStyle(
                        color: c.text3,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          fmtRate(controller.currentRate),
                          style: TextStyle(
                            color: c.text,
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.02,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 10),
                        BadgeChip(
                          label:
                              '${controller.isUp ? '+' : ''}${controller.pctChange.toStringAsFixed(2)}%',
                          tone: controller.isUp ? BadgeTone.up : BadgeTone.down,
                          leading: Icon(
                            controller.isUp
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            color: controller.isUp ? c.up : c.down,
                            size: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (controller.isFromCache.value)
                BadgeChip(
                  label: 'Cached',
                  tone: BadgeTone.warn,
                  leading: Icon(Icons.storage_rounded, color: c.warn, size: 12),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (controller.isLoading.value)
            SizedBox(
              height: 210,
              child: Center(
                child: CircularProgressIndicator(
                  color: kAccent,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            AreaChartWidget(
              points: controller.historyPoints,
              height: 210,
            ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.controller, required this.c});
  final HistoryController controller;
  final VfColors c;

  @override
  Widget build(BuildContext context) {
    final days = controller.selectedDays.value;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      padding: EdgeInsets.zero,
      children: [
        _StatCard(
          label: '${days}d high',
          value: fmtRate(controller.hi),
          tone: BadgeTone.up,
          c: c,
        ),
        _StatCard(
          label: '${days}d low',
          value: fmtRate(controller.lo),
          tone: BadgeTone.down,
          c: c,
        ),
        _StatCard(label: 'Average', value: fmtRate(controller.avg), c: c),
        _StatCard(
          label: 'Volatility',
          value: '${controller.volatility.toStringAsFixed(2)}%',
          c: c,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.c,
    this.tone,
  });
  final String label;
  final String value;
  final VfColors c;
  final BadgeTone? tone;

  @override
  Widget build(BuildContext context) {
    Color valueColor = c.text;
    if (tone == BadgeTone.up) valueColor = c.up;
    if (tone == BadgeTone.down) valueColor = c.down;

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
          Text(
            label,
            style: TextStyle(
                color: c.text3, fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 7),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 19,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
                letterSpacing: -0.01,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyTable extends StatelessWidget {
  const _DailyTable({required this.controller, required this.c});
  final HistoryController controller;
  final VfColors c;

  @override
  Widget build(BuildContext context) {
    final rows = controller.historyPoints.reversed.take(14).toList();
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 11),
            child: Row(
              children: [
                Text(
                  'Daily values',
                  style: TextStyle(
                    color: c.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.copy_rounded, size: 13, color: c.text2),
                  label: Text(
                    'CSV',
                    style: TextStyle(color: c.text2, fontSize: 13),
                  ),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                  ),
                ),
              ],
            ),
          ),
          ...rows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            final isToday = i == 0;
            double dchg = 0;
            if (i < rows.length - 1) {
              final prev = rows[i + 1].value;
              if (prev != 0) dchg = ((row.value - prev) / prev) * 100;
            }
            Color dchgColor = c.text3;
            if (dchg > 0) dchgColor = c.up;
            if (dchg < 0) dchgColor = c.down;

            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.border, width: 1)),
              ),
              child: Row(children: [
                Expanded(
                  child: Row(children: [
                    Text(
                      DateFormat('MMM d, y').format(row.date),
                      style: TextStyle(
                        color: c.text,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      BadgeChip(
                        label: 'Today',
                        tone: BadgeTone.accent,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                      ),
                    ],
                  ]),
                ),
                Text(
                  fmtRate(row.value),
                  style: TextStyle(
                    color: c.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 70,
                  child: Text(
                    '${dchg > 0 ? '▲' : dchg < 0 ? '▼' : ''}${dchg.abs().toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: dchgColor,
                      fontSize: 12.5,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ]),
            );
          }),
        ],
      ),
    );
  }
}
