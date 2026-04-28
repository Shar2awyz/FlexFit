import 'package:flutter/material.dart';

extension AppColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ── page / scaffold ──────────────────────────────────────────────────────
  Color get pageBg =>
      isDark ? const Color(0xFF1E3A8A) : const Color(0xFFF0F5FF);
  Color get deepBg =>
      isDark ? const Color(0xFF0A1F44) : const Color(0xFFE4EEFF);
  Color get workoutBg =>
      isDark ? const Color(0xFF0D1B3E) : const Color(0xFFF5F8FF);

  // ── cards / surfaces ────────────────────────────────────────────────────
  Color get cardBg => isDark ? const Color(0xFF2E4C8C) : Colors.white;
  Color get cardAlt =>
      isDark ? const Color(0xFF3F5E8F) : const Color(0xFFEEF4FF);
  Color get innerCard =>
      isDark ? const Color(0xFF1A2E5C) : const Color(0xFFF0F5FF);
  Color get rowBg =>
      isDark ? const Color(0xFF243B72) : const Color(0xFFE8EFFF);
  Color get navBg =>
      isDark ? const Color(0xFF0A1F44) : Colors.white;

  // ── text ────────────────────────────────────────────────────────────────
  Color get textPrimary =>
      isDark ? Colors.white : const Color(0xFF0F1F44);
  Color get textSecondary =>
      isDark ? const Color(0xFFB3C5E0) : const Color(0xFF3D5A8A);
  Color get textMuted =>
      isDark ? Colors.white38 : const Color(0xFF7A9CC3);
  Color get textHint =>
      isDark ? Colors.white24 : const Color(0xFFADC3DA);

  // ── accent ──────────────────────────────────────────────────────────────
  Color get accent => const Color(0xFF3B82F6);
  Color get accentLight =>
      isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
  Color get accentBg =>
      isDark
          ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
          : const Color(0xFF3B82F6).withValues(alpha: 0.1);

  // ── misc ────────────────────────────────────────────────────────────────
  Color get divider =>
      isDark ? Colors.white12 : const Color(0xFFDDE6F5);
  Color get iconBg =>
      isDark ? Colors.white10 : const Color(0xFFDEE8FF);
  Color get border =>
      isDark
          ? Colors.white.withValues(alpha: 0.06)
          : const Color(0xFFCDD9F0);

  // ── AppBar ──────────────────────────────────────────────────────────────
  Color get appBarBg =>
      isDark ? const Color(0xFF1E3A8A) : const Color(0xFF1D4ED8);

  // ── icon colors on surfaces ─────────────────────────────────────────────
  Color get iconColor =>
      isDark ? Colors.white : const Color(0xFF0F1F44);
  Color get iconMuted =>
      isDark ? Colors.white38 : const Color(0xFF7A9CC3);

  // ── shadow ──────────────────────────────────────────────────────────────
  List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.2)
              : const Color(0xFF3B82F6).withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}
