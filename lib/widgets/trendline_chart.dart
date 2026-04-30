import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/solo_leveling_theme.dart';

/// A single point on a trendline.
class TrendPoint {
  final DateTime date;
  final double value;
  const TrendPoint(this.date, this.value);
}

/// A small line chart sized for embedding in cards. Shows a single series
/// over time with an optional fill underneath. Empty-state safe.
class TrendlineChart extends StatelessWidget {
  final List<TrendPoint> points;
  final String unit;
  final Color lineColor;
  final double height;
  final bool showDots;

  /// Optional reference line (e.g. previous PR or target weight).
  final double? referenceY;
  final String? referenceLabel;

  const TrendlineChart({
    super.key,
    required this.points,
    this.unit = '',
    this.lineColor = SoloLevelingTheme.primaryCyan,
    this.height = 180,
    this.showDots = true,
    this.referenceY,
    this.referenceLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'NO DATA YET',
            style: TextStyle(
              color: SoloLevelingTheme.textMuted,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
        ),
      );
    }

    // Map dates to ascending x positions (0..n-1) for stable rendering.
    final sorted = [...points]..sort((a, b) => a.date.compareTo(b.date));
    final spots = <FlSpot>[
      for (var i = 0; i < sorted.length; i++)
        FlSpot(i.toDouble(), sorted[i].value),
    ];

    final values = sorted.map((p) => p.value).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    // Add a little padding around the y-range so the line isn't flush against edges.
    final pad = ((maxY - minY).abs() * 0.15).clamp(1.0, double.infinity);
    final yMin = (minY - pad);
    final yMax = (maxY + pad);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (sorted.length - 1).toDouble().clamp(0, double.infinity),
          minY: yMin,
          maxY: yMax,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: ((yMax - yMin) / 4).abs().clamp(0.1, double.infinity),
            getDrawingHorizontalLine: (_) => FlLine(
              color: SoloLevelingTheme.textMuted.withOpacity(0.15),
              strokeWidth: 1,
              dashArray: const [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    color: SoloLevelingTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  // Only show labels at start, middle, and end to avoid clutter.
                  final i = value.round();
                  if (i != 0 && i != sorted.length - 1 && i != sorted.length ~/ 2) {
                    return const SizedBox.shrink();
                  }
                  if (i < 0 || i >= sorted.length) return const SizedBox.shrink();
                  final d = sorted[i].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${d.day}/${d.month}',
                      style: TextStyle(
                        color: SoloLevelingTheme.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          extraLinesData: referenceY == null
              ? const ExtraLinesData()
              : ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: referenceY!,
                      color: SoloLevelingTheme.xpGold.withOpacity(0.6),
                      strokeWidth: 1,
                      dashArray: const [3, 3],
                      label: HorizontalLineLabel(
                        show: referenceLabel != null,
                        labelResolver: (_) => referenceLabel ?? '',
                        style: const TextStyle(
                          color: SoloLevelingTheme.xpGold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => SoloLevelingTheme.backgroundElevated,
              getTooltipItems: (spots) => spots.map((s) {
                final i = s.x.round().clamp(0, sorted.length - 1);
                final d = sorted[i].date;
                return LineTooltipItem(
                  '${s.y.toStringAsFixed(1)}$unit\n${d.day}/${d.month}/${d.year}',
                  const TextStyle(
                    color: SoloLevelingTheme.textPrimary,
                    fontSize: 11,
                  ),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.25,
              color: lineColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: showDots,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                  radius: 3,
                  color: lineColor,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    lineColor.withOpacity(0.25),
                    lineColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
