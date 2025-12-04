import 'package:flutter/material.dart';

class FancyCheckbox extends StatefulWidget {
  final bool isChecked;
  final ValueChanged<bool?>? onChanged;
  final Color activeColor;
  final Color inactiveBorderColor;
  final Color checkColor;
  final double size;
  final Duration animationDuration;
  final IconData icon; // Dieses Icon wird nun genutzt

  const FancyCheckbox({
    super.key,
    required this.isChecked,
    this.onChanged,
    this.activeColor = const Color(0xFF06C167), // Uber Green
    this.inactiveBorderColor = Colors.grey,
    this.checkColor = Colors.white,
    this.size = 60.0,
    this.animationDuration = const Duration(milliseconds: 400),
    required this.icon,
  });

  @override
  State<FancyCheckbox> createState() => _FancyCheckboxState();
}

class _FancyCheckboxState extends State<FancyCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    // Skalierungseffekt beim Aktivieren
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Animation für das Zeichnen des Hakens
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Farbübergang von Grau zu Grün
    _colorAnimation =
        ColorTween(
          begin: widget.inactiveBorderColor,
          end: widget.activeColor,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
          ),
        );

    if (widget.isChecked) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant FancyCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isChecked != oldWidget.isChecked) {
      if (widget.isChecked) {
        _animationController.forward(from: 0.0);
      } else {
        // Bei Deaktivierung ohne Animation zurücksetzen (wie gewünscht)
        _animationController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged?.call(!widget.isChecked);
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final currentColor = _colorAnimation.value;
          final currentScale = _scaleAnimation.value;

          return Transform.scale(
            scale: widget.isChecked ? currentScale : 1.0,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Wenn gecheckt: Hintergrundfarbe animiert, sonst transparent
                color: widget.isChecked ? currentColor : Colors.transparent,
                border: Border.all(
                  color: widget.isChecked ? currentColor! : Colors.transparent,
                  width: 2.0,
                ),
              ),
              // HIER IST DIE ÄNDERUNG:
              child: widget.isChecked
                  ? Center(
                      child: CustomPaint(
                        painter: _CheckPainter(
                          progress: _checkAnimation.value,
                          checkColor: widget.checkColor,
                          strokeWidth: 3.0,
                        ),
                        size: Size(widget.size * 0.5, widget.size * 0.5),
                      ),
                    )
                  : Icon(
                      widget.icon,
                      color: widget.inactiveBorderColor,
                      // Icon-Größe relativ zur Container-Größe (z.B. 50%)
                      size: widget.size * 0.9,
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;
  final Color checkColor;
  final double strokeWidth;

  _CheckPainter({
    required this.progress,
    required this.checkColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = checkColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth;

    final path = Path();
    // Koordinaten für den Haken
    final Offset start = Offset(size.width * 0.1, size.height * 0.5);
    final Offset corner = Offset(size.width * 0.4, size.height * 0.8);
    final Offset end = Offset(size.width * 0.9, size.height * 0.2);

    if (progress < 0.5) {
      final double segmentProgress = progress / 0.5;
      path.moveTo(start.dx, start.dy);
      path.lineTo(
        start.dx + (corner.dx - start.dx) * segmentProgress,
        start.dy + (corner.dy - start.dy) * segmentProgress,
      );
    } else {
      path.moveTo(start.dx, start.dy);
      path.lineTo(corner.dx, corner.dy);
      final double segmentProgress = (progress - 0.5) / 0.5;
      path.lineTo(
        corner.dx + (end.dx - corner.dx) * segmentProgress,
        corner.dy + (end.dy - corner.dy) * segmentProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.checkColor != checkColor;
  }
}
