import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/presentation/home/home_controller.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

class MiniProgressChart extends StatelessWidget {
  const MiniProgressChart({super.key, required this.points});

  final List<MetricSparkPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return const SizedBox.shrink();
    }

    final List<MetricSparkPoint> sorted = List<MetricSparkPoint>.from(points)
      ..sort((a, b) => a.date.compareTo(b.date));

    final List<FlSpot> spots = <FlSpot>[];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    for (int i = 0; i < sorted.length; i += 1) {
      final double value = sorted[i].value;
      minY = minY < value ? minY : value;
      maxY = maxY > value ? maxY : value;
      spots.add(FlSpot(i.toDouble(), value));
    }

    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.veryLightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Peso reciente',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: (spots.length / 4).clamp(1, double.infinity),
                      getTitlesWidget: (value, meta) {
                        final int index = value.round();
                        if (index < 0 || index >= sorted.length) {
                          return const SizedBox.shrink();
                        }
                        final DateTime date = sorted[index].date;
                        final String label =
                            '${date.day}/${date.month.toString().padLeft(2, '0')}';
                        return Text(
                          label,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: minY - 0.2,
                maxY: maxY + 0.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 3,
                    color: AppColors.accentBlue,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentBlue.withValues(alpha: 0.25),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
