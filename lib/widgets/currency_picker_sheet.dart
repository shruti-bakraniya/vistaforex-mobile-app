import 'package:flutter/material.dart';
import '../app/colors.dart';
import '../data/currencies.dart';
import '../data/models.dart';
import 'badge_chip.dart';
import 'currency_token.dart';
import 'animated_number.dart';

class CurrencyPickerSheet extends StatefulWidget {
  const CurrencyPickerSheet({
    super.key,
    required this.side,
    required this.fromCode,
    required this.toCode,
    required this.rates,
    required this.onSelect,
  });

  final String side; // 'from' | 'to'
  final String fromCode;
  final String toCode;
  final Map<String, double> rates;
  final ValueChanged<String> onSelect;

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = VfColors(dark: dark);

    final selected =
        widget.side == 'from' ? widget.fromCode : widget.toCode;
    final base =
        widget.side == 'from' ? widget.toCode : widget.fromCode;

    final ql = _query.trim().toLowerCase();
    final popular = kCurrencies
        .where((c) => kPopularCurrencies.contains(c.code))
        .toList();
    final match = (Currency cur) =>
        ql.isEmpty ||
        cur.code.toLowerCase().contains(ql) ||
        cur.name.toLowerCase().contains(ql) ||
        cur.symbol.toLowerCase().contains(ql);

    final results = kCurrencies.where(match).toList();
    final popularFiltered = ql.isEmpty ? popular : <Currency>[];
    final restFiltered =
        ql.isEmpty ? kCurrencies.where((c) => !kPopularCurrencies.contains(c.code)).toList() : results;

    double crossRate(String code) {
      final fromR = widget.rates[base] ?? 1.0;
      final toR = widget.rates[code] ?? 1.0;
      if (fromR == 0) return 0;
      return toR / fromR;
    }

    Widget row(Currency cur) {
      final isSel = cur.code == selected;
      final rate = crossRate(cur.code);
      return InkWell(
        onTap: () => widget.onSelect(cur.code),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: isSel
              ? BoxDecoration(
                  color: c.accentSoft,
                  borderRadius: BorderRadius.circular(14),
                )
              : null,
          child: Row(
            children: [
              CurrencyToken(code: cur.code, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(
                        cur.code,
                        style: TextStyle(
                          color: c.text,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 7),
                      if (cur.code == widget.fromCode)
                        BadgeChip(
                          label: 'FROM',
                          tone: BadgeTone.accent,
                          fontSize: 10,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                        ),
                      if (cur.code == widget.toCode)
                        BadgeChip(
                          label: 'TO',
                          tone: BadgeTone.neutral,
                          fontSize: 10,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                        ),
                    ]),
                    const SizedBox(height: 1),
                    Text(
                      cur.name,
                      style: TextStyle(
                        color: c.text2,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (widget.rates.isNotEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      fmtRate(rate),
                      style: TextStyle(
                        color: c.text2,
                        fontSize: 12.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'per 1 $base',
                      style: TextStyle(color: c.text3, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
              if (isSel)
                Icon(Icons.check_rounded, color: kAccent, size: 17),
            ],
          ),
        ),
      );
    }

    Widget sectionLabel(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: c.text3,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.07,
            ),
          ),
        );

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.6 : 0.14),
                blurRadius: 60,
              ),
            ],
          ),
          child: Column(
            children: [
              // Grabber
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: c.border2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Select ${widget.side == 'from' ? 'source' : 'target'} currency',
                      style: TextStyle(
                        color: c.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: c.surface2,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded,
                            color: c.text2, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: c.surface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search_rounded, color: c.text3, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: (v) => setState(() => _query = v),
                        style: TextStyle(color: c.text, fontSize: 14.5),
                        decoration: InputDecoration(
                          hintText: 'Search ${kCurrencies.length} currencies…',
                          hintStyle: TextStyle(color: c.text3, fontSize: 14.5),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: c.text3, size: 15),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      ),
                  ]),
                ),
              ),
              const SizedBox(height: 4),
              // List
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 24),
                  children: [
                    if (popularFiltered.isNotEmpty) ...[
                      sectionLabel('Popular'),
                      ...popularFiltered.map(row),
                      sectionLabel('All currencies'),
                    ],
                    ...restFiltered.map(row),
                    if (results.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(children: [
                          Icon(Icons.search_rounded, color: c.text3, size: 24),
                          const SizedBox(height: 10),
                          Text(
                            'No currency matches "$_query".',
                            style: TextStyle(color: c.text3, fontSize: 14),
                          ),
                        ]),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<String?> showCurrencyPicker(
  BuildContext context, {
  required String side,
  required String fromCode,
  required String toCode,
  required Map<String, double> rates,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    useSafeArea: true,
    builder: (_) => CurrencyPickerSheet(
      side: side,
      fromCode: fromCode,
      toCode: toCode,
      rates: rates,
      onSelect: (code) => Navigator.pop(context, code),
    ),
  );
}
