import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';

/// Onboarding screen - "You have been chosen as a Player"
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  final _nameController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _nextStep() {
    _animController.reverse().then((_) {
      setState(() => _step++);
      _animController.forward();
    });
  }

  void _createPlayer() async {
    if (_nameController.text.isEmpty) return;

    final game = context.read<GameProvider>();
    await game.createPlayer(_nameController.text);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SoloLevelingTheme.backgroundDark,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildChosenStep();
      case 2:
        return _buildNameStep();
      default:
        return _buildWelcomeStep();
    }
  }

  Widget _buildWelcomeStep() {
    return GestureDetector(
      onTap: _nextStep,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(
                  color: SoloLevelingTheme.primaryCyan,
                  width: 2,
                ),
                boxShadow: SoloLevelingTheme.glowEffect(
                  SoloLevelingTheme.primaryCyan,
                ),
              ),
              child: Column(
                children: const [
                  Text(
                    '[SYSTEM]',
                    style: TextStyle(
                      color: SoloLevelingTheme.primaryCyan,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'CONNECTION\nESTABLISHED',
                    style: TextStyle(
                      color: SoloLevelingTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'TAP TO CONTINUE',
              style: TextStyle(
                color: SoloLevelingTheme.textMuted,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChosenStep() {
    return GestureDetector(
      onTap: _nextStep,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glowing effect
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: SoloLevelingTheme.primaryCyan.withOpacity(0.3),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: SoloLevelingTheme.primaryCyan,
                        ),
                      ),
                      child: const Text(
                        'SYSTEM MESSAGE',
                        style: TextStyle(
                          color: SoloLevelingTheme.primaryCyan,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'YOU HAVE BEEN\nCHOSEN',
                      style: TextStyle(
                        color: SoloLevelingTheme.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'AS A PLAYER',
                      style: TextStyle(
                        color: SoloLevelingTheme.primaryCyan,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: SoloLevelingTheme.primaryCyan.withOpacity(0.3),
                  ),
                ),
                child: const Text(
                  'Your daily quests await.\nComplete them to grow stronger.\nFailure is not an option.',
                  style: TextStyle(
                    color: SoloLevelingTheme.textSecondary,
                    fontSize: 12,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'TAP TO CONTINUE',
                style: TextStyle(
                  color: SoloLevelingTheme.textMuted,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: SoloLevelingTheme.backgroundCard,
                border: Border.all(
                  color: SoloLevelingTheme.primaryCyan.withOpacity(0.5),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    '[SYSTEM]',
                    style: TextStyle(
                      color: SoloLevelingTheme.primaryCyan,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ENTER YOUR NAME',
                    style: TextStyle(
                      color: SoloLevelingTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: SoloLevelingTheme.primaryCyan,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    decoration: InputDecoration(
                      hintText: 'HUNTER',
                      hintStyle: TextStyle(
                        color: SoloLevelingTheme.textMuted.withOpacity(0.5),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: SoloLevelingTheme.primaryCyan.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: SoloLevelingTheme.primaryCyan,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: _createPlayer,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: SoloLevelingTheme.primaryCyan.withOpacity(0.2),
                        border: Border.all(
                          color: SoloLevelingTheme.primaryCyan,
                        ),
                      ),
                      child: const Text(
                        'BEGIN',
                        style: TextStyle(
                          color: SoloLevelingTheme.primaryCyan,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your journey as a Player begins now',
              style: TextStyle(
                color: SoloLevelingTheme.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
