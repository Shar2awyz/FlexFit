import 'dart:ui';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A0C), // Very dark background
      body: Stack(
        children: [
          // ── Radial Glow Background Effects ─────────────────────────────────
          // Teal-blue glow on the right-middle side
          Positioned(
            right: -80,
            top: MediaQuery.of(context).size.height * 0.4,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00B4D8).withValues(alpha: 0.12),
              ),
            ),
          ),
          // Warm gold/orange glow at the bottom-right
          Positioned(
            right: -40,
            bottom: MediaQuery.of(context).size.height * 0.15,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE2B953).withValues(alpha: 0.08),
              ),
            ),
          ),
          // Apply BackdropFilter for smooth premium blur blending
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 90.0, sigmaY: 90.0),
              child: Container(color: Colors.transparent),
            ),
          ),

          // ── Splash Content ────────────────────────────────────────────────
          SafeArea(
            child: SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40), // Top spacing

                  // Center content (Logo, text, loading indicator)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App Icon Container with shadow/glow
                      Container(
                        width: 156,
                        height: 156,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00B4D8).withValues(alpha: 0.25),
                              blurRadius: 40,
                              spreadRadius: -4,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(36),
                          child: Image.asset(
                            'images/app_icon.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback if asset isn't ready/found
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.fitness_center_rounded,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Brand Text "Flex Fit"
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'Flex',
                              style: TextStyle(
                                color: Color(0xFF00B4D8), // Bright cyan
                              ),
                            ),
                            TextSpan(
                              text: 'Fit',
                              style: TextStyle(
                                color: Color(0xFFC4B892), // Warm soft gold/tan
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Linear Progress Loading Bar
                      SizedBox(
                        width: 100,
                        height: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1.5),
                          child: const LinearProgressIndicator(
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF007AFF), // Bright blue progress indicator
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bottom content (Peak performance text + decorative dots)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'PEAK PERFORMANCE',
                        style: TextStyle(
                          color: Color(0xFF6B7280), // Muted grey text
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Three dots matching mockup
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF00B4D8), // Active Cyan dot
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF1E293B), // Dark blue/grey dot
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF2C2720), // Dark brown dot
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24), // Extra bottom padding
                    ],
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
