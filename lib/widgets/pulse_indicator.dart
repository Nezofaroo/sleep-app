import 'package:flutter/material.dart';

/// Animated concentric-ring pulse — used to show the app is actively listening.
/// Rings scale outward and fade, creating a sonar/radar effect.
class PulseIndicator extends StatefulWidget {
  final Color color;
  final double size;
  final int ringCount;
  final Widget? child;

  const PulseIndicator({
    super.key,
    this.color = const Color(0xFF4B6FDB),
    this.size = 80,
    this.ringCount = 3,
    this.child,
  });

  @override
  State<PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<PulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2.2,
      height: widget.size * 2.2,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Animated concentric rings — staggered by 1/ringCount phase.
              for (int i = 0; i < widget.ringCount; i++)
                _buildRing(i / widget.ringCount),
              // Centre solid circle.
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.15),
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
                child: widget.child,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRing(double phaseOffset) {
    final t = (_ctrl.value + phaseOffset) % 1.0;
    final scale = 1.0 + t * 1.2;
    final opacity = (1.0 - t).clamp(0.0, 1.0);
    return Transform.scale(
      scale: scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.color.withValues(alpha: opacity * 0.55),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
