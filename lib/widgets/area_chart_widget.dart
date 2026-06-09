import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app/colors.dart';
import '../data/models.dart';
import 'animated_number.dart';

class AreaChartWidget extends StatefulWidget {
  const AreaChartWidget({
    super.key,
    required this.points,
    this.height = 210,
  });

  final List<RatePoint> points;
  final double height;

  @override
  State<AreaChartWidget> createState() => _AreaChartWidgetState();
}

class _AreaChartWidgetState extends State<AreaChartWidget> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = VfColors(dark: dark);

    if (widget.points.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'No data',
            style: TextStyle(color: c.text3, fontSize: 13),
          ),
        ),
      );
    }

    final values = widget.points.map((p) => p.value).toList();
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final span = (maxV - minV).abs().clamp(double.minPositive, double.infinity);
    final yMin = minV - span * 0.18;
    final yMax = maxV + span * 0.18;

    final spots = List.generate(
      widget.points.length,
      (i) => FlSpot(i.toDouble(), widget.points[i].value),
    );

    return SizedBox(
      height: widget.height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (widget.points.length - 1).toDouble(),
          minY: yMin,
          maxY: yMax,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (_) => FlLine(
              color: c.border.withOpacity(0.8),
              strokeWidth: 1,
              dashArray: [2, 5],
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 58,
                getTitlesWidget: (v, meta) {
                  if (v == meta.min || v == meta.max) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      fmtRate(v),
                      style: TextStyle(
                        color: c.text3,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (v, meta) {
                  final n = widget.points.length;
                  final idx = v.round();
                  final isFirst = idx == 0;
                  final isMid = idx == n ~/ 2;
                  final isLast = idx == n - 1;
                  if (!isFirst && !isMid && !isLast) return const SizedBox();
                  final date = widget.points[idx.clamp(0, n - 1)].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('MMM d').format(date),
                      style: TextStyle(color: c.text3, fontSize: 10.5),
                      textAlign: isFirst
                          ? TextAlign.left
                          : isLast
                              ? TextAlign.right
                              : TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.15,
              color: kAccent,
              barWidth: 2.5,
              dotData: FlDotData(
                show: _touchedIndex != null,
                getDotPainter: (spot, pct, bar, idx) {
                  if (idx != _touchedIndex) {
                    return FlDotCirclePainter(
                      radius: 0,
                      color: Colors.transparent,
                    );
                  }
                  return FlDotCirclePainter(
                    radius: 4.5,
                    color: c.surface,
                    strokeWidth: 2.5,
                    strokeColor: kAccent,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    kAccent.withOpacity(0.30),
                    kAccent.withOpacity(0.08),
                    kAccent.withOpacity(0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((i) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: kAccent.withOpacity(0.3),
                    strokeWidth: 1.5,
                    dashArray: [3, 4],
                  ),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                      radius: 4.5,
                      color: c.surface,
                      strokeWidth: 2.5,
                      strokeColor: kAccent,
                    ),
                  ),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => c.surface,
              tooltipBorderRadius: BorderRadius.circular(10),
              tooltipBorder: BorderSide(color: c.border2),
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 8,
              ),
              getTooltipItems: (spots) => spots.map((s) {
                final idx = s.x.round().clamp(0, widget.points.length - 1);
                final pt = widget.points[idx];
                return LineTooltipItem(
                  '${DateFormat('MMM d, y').format(pt.date)}\n',
                  TextStyle(
                    color: c.text3,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(
                      text: fmtRate(s.y),
                      style: TextStyle(
                        color: c.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            touchCallback: (event, response) {
              setState(() {
                if (!event.isInterestedForInteractions) {
                  _touchedIndex = null;
                } else {
                  final spots = response?.lineBarSpots;
                  _touchedIndex = (spots != null && spots.isNotEmpty)
                      ? spots.first.x.round()
                      : null;
                }
              });
            },
          ),
        ),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
      ),
    );
  }
}
