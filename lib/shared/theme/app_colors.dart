import 'package:flutter/material.dart';

/// Professional gray color palette for My Fitness Tracker.
///
/// This palette provides a sophisticated, modern look with gray as the primary
/// color family, complemented by blue accents for interactive elements.
class AppColors {
  AppColors._();

  // ============================================================================
  // PRIMARY GRAYS
  // ============================================================================

  /// Dark gray - Primary backgrounds, headers
  static const Color darkGray = Color(0xFF2C2C2E);

  /// Medium dark gray - Secondary backgrounds
  static const Color mediumDarkGray = Color(0xFF3A3A3C);

  /// Medium gray - Borders, dividers
  static const Color mediumGray = Color(0xFF48484A);

  /// Light gray - Surface backgrounds
  static const Color lightGray = Color(0xFFF2F2F7);

  /// Very light gray - Subtle backgrounds
  static const Color veryLightGray = Color(0xFFF9F9F9);

  /// Pure white - Cards, content
  static const Color white = Color(0xFFFFFFFF);

  // ============================================================================
  // TEXT COLORS (GRAY HIERARCHY)
  // ============================================================================

  /// Primary text - Nearly black
  static const Color textPrimary = Color(0xFF1C1C1E);

  /// Secondary text - Medium gray
  static const Color textSecondary = Color(0xFF8E8E93);

  /// Tertiary text - Light gray
  static const Color textTertiary = Color(0xFFAEAEB2);

  /// Disabled text - Very light gray
  static const Color textDisabled = Color(0xFFC7C7CC);

  // ============================================================================
  // ACCENT COLORS
  // ============================================================================

  /// Primary accent - iOS blue for CTAs
  static const Color accentBlue = Color(0xFF007AFF);

  /// Light blue - Hover states, backgrounds
  static const Color lightBlue = Color(0xFF5AC8FA);

  /// Dark blue - Pressed states
  static const Color darkBlue = Color(0xFF0051D5);

  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================

  /// Success - Green
  static const Color success = Color(0xFF34C759);

  /// Warning - Orange
  static const Color warning = Color(0xFFFF9500);

  /// Error - Red
  static const Color error = Color(0xFFFF3B30);

  /// Info - Teal
  static const Color info = Color(0xFF5AC8FA);

  // ============================================================================
  // CHART COLORS (GRAY GRADIENTS)
  // ============================================================================

  /// Chart gradient start - Dark gray
  static const Color chartGradientStart = Color(0xFF6E6E73);

  /// Chart gradient middle - Medium gray
  static const Color chartGradientMiddle = Color(0xFF8E8E93);

  /// Chart gradient end - Light gray
  static const Color chartGradientEnd = Color(0xFFAEAEB2);

  // ============================================================================
  // SHADOW COLORS
  // ============================================================================

  /// Light shadow - For cards on light backgrounds
  static const Color shadowLight = Color(0x0F000000);

  /// Medium shadow - For elevated cards
  static const Color shadowMedium = Color(0x1A000000);

  /// Dark shadow - For modals, dialogs
  static const Color shadowDark = Color(0x33000000);

  // ============================================================================
  // GRADIENTS
  // ============================================================================

  /// Professional gray gradient for backgrounds
  static const LinearGradient grayGradient = LinearGradient(
    colors: [mediumDarkGray, darkGray],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle gray gradient for cards
  static const LinearGradient subtleGrayGradient = LinearGradient(
    colors: [veryLightGray, lightGray],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Chart gradient (gray tones)
  static const LinearGradient chartGradient = LinearGradient(
    colors: [chartGradientStart, chartGradientMiddle, chartGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
