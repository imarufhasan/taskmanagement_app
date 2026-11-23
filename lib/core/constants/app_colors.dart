import 'package:flutter/material.dart';

class AppColors {
  // Primary & Accent (Indigo & Blue palette)
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 800
  static const Color secondary = Color(0xFF0EA5E9); // Sky 500

  // Semantic Status Colors
  static const Color statusPending = Color(0xFFF59E0B); // Amber 500
  static const Color statusInProgress = Color(0xFF3B82F6); // Blue 500
  static const Color statusCompleted = Color(0xFF10B981); // Emerald 500

  // Semantic Priority Colors
  static const Color priorityLow = Color(0xFF64748B); // Slate 500
  static const Color priorityMedium = Color(0xFF3B82F6); // Blue 500
  static const Color priorityHigh = Color(0xFFF97316); // Orange 500
  static const Color priorityUrgent = Color(0xFFEF4444); // Red 500

  // Background & Surfaces (Light)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Background & Surfaces (Dark)
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color cardDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
}
