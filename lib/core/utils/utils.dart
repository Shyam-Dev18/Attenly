import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

Color hexToColor(String hex) {
  final hexCode = hex.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}

Color attendanceColor(double pct, int goal) {
  if (pct >= goal) return kPresent;
  if (pct >= 60) return kAmber;
  return kAbsent;
}

String percentageLabel(double pct) => '${pct.toStringAsFixed(1)}%';
