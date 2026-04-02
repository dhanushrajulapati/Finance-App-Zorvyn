import 'package:flutter/material.dart';

class AppConstants {
  // Supabase configurations
  static const String supabaseUrl = 'https://tailbgbamxpffumzpepq.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRhaWxiZ2JhbXhwZmZ1bXpwZXBxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxMDg2MjUsImV4cCI6MjA5MDY4NDYyNX0.oPizZthNQmCr6SVoEKbp2L0zMRxLehV5fugSbAdzRgQ';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 16.0;
}

class AppColors {
  static const primary = Color(0xFF14B8A6); // Teal 500
  static const primaryDark = Color(0xFF0F766E); // Teal 700
  static const secondary = Color(0xFF3B82F6); // Blue 500
  static const background = Color(0xFFF3F4F6); // Gray 100
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1F2937); // Gray 800
  static const textSecondary = Color(0xFF6B7280); // Gray 500

  static const income = Color(0xFF10B981); // Emerald 500
  static const expense = Color(0xFFEF4444); // Red 500

  // Dark Theme Palette
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkTextPrimary = Color(0xFFE0E0E0);
  static const darkTextSecondary = Color(0xFF9E9E9E);
}
