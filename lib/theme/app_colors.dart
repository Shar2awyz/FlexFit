import 'package:flutter/material.dart';

extension AppColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ── page / scaffold ───────────────────────────────────────────────
  Color get pageBg =>
      isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

  Color get deepBg =>
      isDark ? const Color(0xFF020617) : const Color(0xFFE2E8F0);

  Color get workoutBg =>
      isDark ? const Color(0xFF111827) : const Color(0xFFF1F5F9);

  // ── cards / surfaces ──────────────────────────────────────────────
  Color get cardBg =>
      isDark ? const Color(0xFF1E293B) : Colors.white;

  Color get cardAlt =>
      isDark ? const Color(0xFF273449) : const Color(0xFFF8FAFC);

  Color get innerCard =>
      isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  Color get rowBg =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

  Color get navBg =>
      isDark ? const Color(0xFF020617) : Colors.white;

  // ── text ──────────────────────────────────────────────────────────
  Color get textPrimary =>
      isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

  Color get textSecondary =>
      isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);

  Color get textMuted =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  Color get textHint =>
      isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  // ── accent ────────────────────────────────────────────────────────
  Color get accent => const Color(0xFF3B82F6);

  Color get accentLight =>
      isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);

  Color get accentBg =>
      isDark
          ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
          : const Color(0xFFDBEAFE);

  // ── status colors ─────────────────────────────────────────────────
  Color get success => const Color(0xFF22C55E);

  Color get warning => const Color(0xFFF59E0B);

  Color get danger => const Color(0xFFEF4444);

  // ── misc ──────────────────────────────────────────────────────────
  Color get divider =>
      isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  Color get iconBg =>
      isDark ? const Color(0xFF243244) : const Color(0xFFEFF6FF);

  Color get border =>
      isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  // ── AppBar ────────────────────────────────────────────────────────
  Color get appBarBg =>
      isDark ? const Color(0xFF0F172A) : Colors.white;

  // ── icons ─────────────────────────────────────────────────────────
  Color get iconColor =>
      isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

  Color get iconMuted =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  // ── shadows ───────────────────────────────────────────────────────
  List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
      ];
}