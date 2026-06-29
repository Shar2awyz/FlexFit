import 'package:flutter/material.dart';
import 'package:flex_fit/theme/app_colors.dart';

class CongratsPRDialog extends StatelessWidget {
  final List<String> achievedPRs;

  const CongratsPRDialog({
    super.key,
    required this.achievedPRs,
  });

  static Future<void> show(BuildContext context, List<String> achievedPRs) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Congrats',
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.elasticOut);
        return Transform.scale(
          scale: curve.value,
          child: Opacity(
            opacity: anim1.value,
            child: CongratsPRDialog(achievedPRs: achievedPRs),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: sw * 0.08),
      child: Container(
        decoration: BoxDecoration(
          color: context.deepBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.2),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: Image.asset(
                'images/congrats_pr.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.all(sw * 0.06),
              child: Column(
                children: [
                  // Gold/Amber Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.amber, Colors.orangeAccent, Colors.yellowAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'GOAL ACHIEVED!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: sw * 0.06,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: sw * 0.02),
                  
                  // Subtitle
                  Text(
                    'Incredible job! You hit 100% of your target on:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: sw * 0.035,
                    ),
                  ),
                  SizedBox(height: sw * 0.04),
                  
                  // List of achieved PRs
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(sw * 0.04),
                    decoration: BoxDecoration(
                      color: context.innerCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.border,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: achievedPRs.map((pr) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: sw * 0.015),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.stars_rounded,
                                color: Colors.amber,
                                size: 20,
                              ),
                              SizedBox(width: sw * 0.02),
                              Expanded(
                                child: Text(
                                  pr,
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: sw * 0.038,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: sw * 0.06),
                  
                  // Dismiss button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'AWESOME!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
