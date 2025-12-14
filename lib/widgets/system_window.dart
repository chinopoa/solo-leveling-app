import 'package:flutter/material.dart';
import '../theme/solo_leveling_theme.dart';

/// A styled window that mimics the System UI from Solo Leveling
class SystemWindow extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final double? width;
  final double? height;

  const SystemWindow({
    super.key,
    this.title,
    required this.child,
    this.padding,
    this.showCloseButton = false,
    this.onClose,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: SoloLevelingTheme.systemWindowDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) _buildHeader(),
          Flexible(
            child: Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: SoloLevelingTheme.primaryCyan.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: SoloLevelingTheme.primaryCyan.withOpacity(0.5),
              ),
            ),
            child: Text(
              '[SYSTEM]',
              style: TextStyle(
                color: SoloLevelingTheme.primaryCyan,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title!,
              style: const TextStyle(
                color: SoloLevelingTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          if (showCloseButton)
            GestureDetector(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.close,
                  color: SoloLevelingTheme.primaryCyan,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Animated system message popup
class SystemMessage extends StatefulWidget {
  final String message;
  final VoidCallback? onDismiss;
  final Duration displayDuration;

  const SystemMessage({
    super.key,
    required this.message,
    this.onDismiss,
    this.displayDuration = const Duration(seconds: 3),
  });

  @override
  State<SystemMessage> createState() => _SystemMessageState();
}

class _SystemMessageState extends State<SystemMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss?.call());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SystemWindow(
          child: Text(
            widget.message,
            style: const TextStyle(
              color: SoloLevelingTheme.primaryCyan,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
