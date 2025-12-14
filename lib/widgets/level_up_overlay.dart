import 'package:flutter/material.dart';
import '../theme/solo_leveling_theme.dart';

/// Full-screen level up celebration overlay
class LevelUpOverlay extends StatefulWidget {
  final int newLevel;
  final int pointsGained;
  final VoidCallback onDismiss;

  const LevelUpOverlay({
    super.key,
    required this.newLevel,
    required this.pointsGained,
    required this.onDismiss,
  });

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeIn),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return Container(
            color: Colors.black.withOpacity(0.85 * _fadeAnimation.value),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glowing effect behind text
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: SoloLevelingTheme.primaryCyan
                                        .withOpacity(0.3),
                                    blurRadius: 60,
                                    spreadRadius: 20,
                                  ),
                                  BoxShadow(
                                    color: SoloLevelingTheme.accentPurple
                                        .withOpacity(0.2),
                                    blurRadius: 100,
                                    spreadRadius: 40,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // LEVEL UP text
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                      colors: [
                                        SoloLevelingTheme.primaryCyan,
                                        SoloLevelingTheme.accentPurple,
                                        SoloLevelingTheme.primaryCyan,
                                      ],
                                    ).createShader(bounds),
                                    child: const Text(
                                      'LEVEL UP',
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Level number
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: SoloLevelingTheme.primaryCyan,
                                        width: 2,
                                      ),
                                      boxShadow:
                                          SoloLevelingTheme.glowEffect(
                                        SoloLevelingTheme.primaryCyan,
                                      ),
                                    ),
                                    child: Text(
                                      'LV. ${widget.newLevel}',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: SoloLevelingTheme.primaryCyan,
                                        letterSpacing: 4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      // Points gained
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: SoloLevelingTheme.backgroundCard,
                          border: Border.all(
                            color:
                                SoloLevelingTheme.primaryCyan.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+${widget.pointsGained} STAT POINTS ACQUIRED',
                          style: const TextStyle(
                            fontSize: 14,
                            color: SoloLevelingTheme.primaryCyan,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Tap to continue
                      Text(
                        'TAP TO CONTINUE',
                        style: TextStyle(
                          fontSize: 12,
                          color: SoloLevelingTheme.textMuted,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
