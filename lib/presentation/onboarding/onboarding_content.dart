import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

class OnboardingPageContent {
  const OnboardingPageContent({
    required this.title,
    required this.subtitle,
    required this.illustration,
    this.background,
  });

  final String title;
  final String subtitle;
  final IconData illustration;
  final Color? background;
}

const List<OnboardingPageContent> onboardingPages = <OnboardingPageContent>[
  OnboardingPageContent(
    title: 'Bienvenido a My Fitness Tracker',
    subtitle:
        'Tu compañero inteligente para planear, registrar y mejorar cada sesión.',
    illustration: Icons.health_and_safety_outlined,
    background: AppColors.accentBlue,
  ),
  OnboardingPageContent(
    title: 'Crea rutinas personalizadas',
    subtitle:
        'Diseña tus entrenamientos con ejercicios a medida y controles avanzados.',
    illustration: Icons.fitness_center_outlined,
  ),
  OnboardingPageContent(
    title: 'Rastrea tu progreso',
    subtitle:
        'Registra métricas corporales y visualiza tu evolución día a día.',
    illustration: Icons.show_chart,
  ),
  OnboardingPageContent(
    title: 'Alcanza tus metas',
    subtitle:
        'Recibe insights, logros y motivación para mantener la constancia.',
    illustration: Icons.emoji_events_outlined,
  ),
];
