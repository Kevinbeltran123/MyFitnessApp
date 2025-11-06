import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

/// BMI Calculator widget with health indicators.
///
/// Displays calculated BMI based on metabolic profile and latest weight.
class BMICalculator extends StatelessWidget {
  const BMICalculator({
    super.key,
    required this.profile,
    required this.latestWeight,
  });

  final MetabolicProfile profile;
  final double latestWeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bmi = _calculateBMI();
    final category = _getBMICategory(bmi);
    final categoryColor = _getCategoryColor(category);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.health_and_safety_outlined,
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Índice de Masa Corporal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Basado en altura y peso actual',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // BMI value and category
          Row(
            children: [
              // BMI Value
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.subtleGrayGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IMC',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        bmi.toStringAsFixed(1),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: categoryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Category
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: categoryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categoría',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: categoryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // BMI Scale indicator
          _buildBMIScale(bmi, theme),
          const SizedBox(height: 12),

          // Additional info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: AppColors.info),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Altura: ${profile.heightCm.toStringAsFixed(0)} cm',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMIScale(double bmi, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escala IMC',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: 8,
              child: Stack(
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF3B82F6), // Underweight - Blue
                          Color(0xFF10B981), // Normal - Green
                          Color(0xFFF59E0B), // Overweight - Orange
                          Color(0xFFEF4444), // Obese - Red
                        ],
                        stops: [0.0, 0.33, 0.66, 1.0],
                      ),
                    ),
                  ),

                  // Current position indicator
                  Positioned(
                    left: _getBMIPosition(bmi) * constraints.maxWidth - 6,
                    top: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.darkGray, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 6),

        // Scale labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '<18.5',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              '18.5',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              '25',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              '30',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              '>30',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _calculateBMI() {
    final heightM = profile.heightCm / 100;
    return latestWeight / (heightM * heightM);
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Bajo peso';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Bajo peso':
        return const Color(0xFF3B82F6); // Blue
      case 'Normal':
        return AppColors.success; // Green
      case 'Sobrepeso':
        return AppColors.warning; // Orange
      case 'Obesidad':
        return AppColors.error; // Red
      default:
        return AppColors.textSecondary;
    }
  }

  double _getBMIPosition(double bmi) {
    // Map BMI to 0-1 scale (15-35 BMI range)
    const minBMI = 15.0;
    const maxBMI = 35.0;
    final clampedBMI = bmi.clamp(minBMI, maxBMI);
    return (clampedBMI - minBMI) / (maxBMI - minBMI);
  }
}
