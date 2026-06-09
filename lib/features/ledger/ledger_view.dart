import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/colors.dart';
import '../../data/currencies.dart';
import '../../data/models.dart';
import '../../widgets/animated_number.dart';
import '../../widgets/currency_token.dart';
import '../home/home_controller.dart';
import 'ledger_controller.dart';

class LedgerView extends GetView<LedgerController> {
  const LedgerView({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();

    return Obx(() {
      final dark = home.isDark.value;
      final c = VfColors(dark: dark);

      return Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ledger',
                          style: TextStyle(
                            color: c.text,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.025,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Obx(() => Text(
                              '${controller.entries.length} saved conversions · on this device',
                              style: TextStyle(
                                color: c.text2,
                                fontSize: 13.5,
                                height: 1.4,
                              ),
                            )),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                _SearchBar(c: c, controller: controller),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Obx(() {
              final groups = controller.groupedByDate;
              if (groups.isEmpty) {
                return _EmptyState(
                  hasQuery: controller.searchQuery.value.isNotEmpty,
                  query: controller.searchQuery.value,
                  c: c,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                itemCount: groups.length,
                itemBuilder: (ctx, i) {
                  final date = groups.keys.elementAt(i);
                  final dayEntries = groups.values.elementAt(i);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 9, left: 2),
                        child: Text(
                          date.toUpperCase(),
                          style: TextStyle(
                            color: c.text3,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.06,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: c.border),
                        ),
                        child: Column(
                          children: dayEntries
                              .asMap()
                              .entries
                              .map((e) => _LedgerRow(
                                    entry: e.value,
                                    isLast: e.key == dayEntries.length - 1,
                                    c: c,
                                    onReuse: () =>
                                        controller.reuse(e.value),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      );
    });
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.c, required this.controller});
  final VfColors c;
  final LedgerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Row(children: [
        const SizedBox(width: 14),
        Icon(Icons.search_rounded, color: c.text3, size: 17),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            onChanged: (v) => controller.searchQuery.value = v,
            style: TextStyle(color: c.text, fontSize: 14.5),
            decoration: InputDecoration(
              hintText: 'Search ledger…',
              hintStyle: TextStyle(color: c.text3, fontSize: 14.5),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
        Obx(() {
          if (controller.searchQuery.value.isEmpty)
            return const SizedBox.shrink();
          return IconButton(
            icon: Icon(Icons.close_rounded, color: c.text3, size: 15),
            onPressed: () => controller.searchQuery.value = '',
          );
        }),
      ]),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.entry,
    required this.isLast,
    required this.c,
    required this.onReuse,
  });
  final ConversionEntry entry;
  final bool isLast;
  final VfColors c;
  final VoidCallback onReuse;

  @override
  Widget build(BuildContext context) {
    final fromCur = getCurrency(entry.from);
    final toCur = getCurrency(entry.to);
    final timeStr = DateFormat('h:mm a').format(entry.timestamp);

    return GestureDetector(
      onTap: onReuse,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: c.border, width: 1)),
        ),
        child: Row(children: [
          // Overlapping token pair
          SizedBox(
            width: 52,
            height: 34,
            child: Stack(children: [
              Positioned(left: 0, child: CurrencyToken(code: entry.from, size: 34)),
              Positioned(
                left: 18,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: c.surface, width: 2),
                  ),
                  child: CurrencyToken(code: entry.to, size: 34),
                ),
              ),
            ]),
          ),
          const SizedBox(width: 13),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.from} → ${entry.to}',
                  style: TextStyle(
                    color: c.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.access_time_rounded, color: c.text3, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    timeStr,
                    style: TextStyle(color: c.text3, fontSize: 11.5),
                  ),
                ]),
              ],
            ),
          ),
          // Amounts
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${toCur.symbol}${fmtMoney(entry.result, 2)}',
                style: TextStyle(
                  color: c.text,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                '${fromCur.symbol}${fmtMoney(entry.amount, 2)} · @${fmtRate(entry.rate)}',
                style: TextStyle(
                  color: c.text3,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Icon(Icons.replay_rounded, color: c.text3, size: 16),
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasQuery,
    required this.query,
    required this.c,
  });
  final bool hasQuery;
  final String query;
  final VfColors c;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasQuery ? Icons.search_rounded : Icons.receipt_long_rounded,
              color: c.text3,
              size: 26,
            ),
            const SizedBox(height: 10),
            Text(
              hasQuery
                  ? 'No conversions match "$query".'
                  : 'No conversions saved yet.',
              style: TextStyle(color: c.text3, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
