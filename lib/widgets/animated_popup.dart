import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/duolingo_theme.dart';

class AnimatedPopup extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onDismiss;
  final Duration duration;

  const AnimatedPopup({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.onDismiss,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  State<AnimatedPopup> createState() => _AnimatedPopupState();
}

class _AnimatedPopupState extends State<AnimatedPopup>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _scaleController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.bounceOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    await _controller.forward();
    await _scaleController.forward();
    
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _scaleController.reverse();
    await _controller.reverse();
    if (mounted) {
      widget.onDismiss?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: 50 + _slideAnimation.value,
          left: 16,
          right: 16,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? DuolingoTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: (widget.iconColor ?? Colors.white).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor ?? Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.message,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _dismiss,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StreakPopup extends StatelessWidget {
  final int streak;
  final VoidCallback? onDismiss;

  const StreakPopup({
    Key? key,
    required this.streak,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPopup(
      title: "🔥 Streak!",
      message: "You've maintained a $streak-day learning streak!",
      icon: Icons.local_fire_department,
      backgroundColor: DuolingoTheme.accentPink,
      iconColor: Colors.orange,
      onDismiss: onDismiss,
    );
  }
}

class AchievementPopup extends StatelessWidget {
  final String achievement;
  final String description;
  final VoidCallback? onDismiss;

  const AchievementPopup({
    Key? key,
    required this.achievement,
    required this.description,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPopup(
      title: "🏆 Achievement Unlocked!",
      message: "$achievement: $description",
      icon: Icons.emoji_events,
      backgroundColor: DuolingoTheme.secondary,
      iconColor: Colors.amber,
      onDismiss: onDismiss,
    );
  }
}

class LessonCompletePopup extends StatelessWidget {
  final String lessonTitle;
  final int xpGained;
  final VoidCallback? onDismiss;

  const LessonCompletePopup({
    Key? key,
    required this.lessonTitle,
    required this.xpGained,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPopup(
      title: "✅ Lesson Complete!",
      message: "You earned $xpGained XP from '$lessonTitle'",
      icon: Icons.check_circle,
      backgroundColor: DuolingoTheme.lessonCompleted,
      iconColor: Colors.white,
      onDismiss: onDismiss,
    );
  }
} 