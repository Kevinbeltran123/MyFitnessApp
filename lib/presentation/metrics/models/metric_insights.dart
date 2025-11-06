enum MetricTrend { up, down, stable }

class ComparisonMetricData {
  const ComparisonMetricData({
    required this.label,
    required this.unit,
    required this.trend,
    this.delta,
    this.percentChange,
    this.average,
  });

  final String label;
  final String unit;
  final MetricTrend trend;
  final double? delta;
  final double? percentChange;
  final double? average;

  bool get hasValue => delta != null;
}

class TrendInsights {
  const TrendInsights({
    required this.title,
    required this.points,
    required this.slope,
    required this.latestValue,
    required this.trend,
    required this.unit,
    this.projectedValue,
  });

  final String title;
  final List<double> points;
  final double slope;
  final double latestValue;
  final MetricTrend trend;
  final String unit;
  final double? projectedValue;

  bool get hasProjection => projectedValue != null;
}
