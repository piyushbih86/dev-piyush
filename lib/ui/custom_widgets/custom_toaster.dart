import 'package:flutter/material.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/controller/toaster_controller.dart';

class CustomToaster extends StatefulWidget {
  const CustomToaster({
    super.key,
    required this.message,
    required this.kind,
    required this.durationMs,
    required this.onDone,
  });

  final String message;
  final ToasterKind kind;
  final int durationMs;
  final VoidCallback onDone;

  @override
  State<CustomToaster> createState() => _CustomToasterState();
}

class _CustomToasterState extends State<CustomToaster>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    const enter = 140;
    const exit = 140;
    final total = widget.durationMs + enter + exit;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: total),
    );
    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: enter / total * 100,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1),
        weight: widget.durationMs / total * 100,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: exit / total * 100,
      ),
    ]).animate(_controller);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onDone();
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _accent {
    switch (widget.kind) {
      case ToasterKind.success:
        return ColorConstants.success;
      case ToasterKind.error:
        return ColorConstants.error;
      case ToasterKind.info:
        return ColorConstants.accent;
    }
  }

  IconData get _icon {
    switch (widget.kind) {
      case ToasterKind.success:
        return Icons.check_circle_rounded;
      case ToasterKind.error:
        return Icons.error_rounded;
      case ToasterKind.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value.clamp(0, 1),
                child: Transform.translate(
                  offset: Offset(0, (1 - _animation.value) * -24),
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ColorConstants.toasterBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _accent.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(_icon, color: _accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: ColorConstants.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
