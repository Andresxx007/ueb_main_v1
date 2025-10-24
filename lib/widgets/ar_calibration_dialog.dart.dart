// =====================================================
// 🧭 AR CALIBRATION DIALOG
// =====================================================
// Guía visual para calibrar la brújula
// =====================================================

import 'package:flutter/material.dart';
import 'dart:math' as math;

class ArCalibrationDialog extends StatefulWidget {
  final VoidCallback onDismiss;

  const ArCalibrationDialog({
    super.key,
    required this.onDismiss,
  });

  @override
  State<ArCalibrationDialog> createState() => _ArCalibrationDialogState();
}

class _ArCalibrationDialogState extends State<ArCalibrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.explore,
                size: 60,
                color: Colors.orange,
              ),

              const SizedBox(height: 20),

              const Text(
                'Calibración de Brújula',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Para mejorar la precisión:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 20),

              // Animación de movimiento en 8
              AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(150, 100),
                    painter: Figure8Painter(
                      progress: _rotationAnimation.value,
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              const Text(
                '1. Mueve el teléfono en forma de 8\n'
                '2. Aleja el dispositivo de objetos metálicos\n'
                '3. Mantén el teléfono en posición vertical',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.left,
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: widget.onDismiss,
                    child: const Text('ENTENDIDO'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Abrir configuración del sistema
                      widget.onDismiss();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('CALIBRAR'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// 🎨 PAINTER PARA ANIMACIÓN DE FIGURA 8
// =====================================================
class Figure8Painter extends CustomPainter {
  final double progress;

  Figure8Painter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Dibujar figura 8 (lemniscata)
    for (double t = 0; t <= 2 * math.pi; t += 0.01) {
      final scale = size.width / 4;
      final x = size.width / 2 + scale * math.sin(t);
      final y = size.height / 2 + scale * math.sin(t) * math.cos(t);

      if (t == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Dibujar punto móvil
    final t = progress;
    final scale = size.width / 4;
    final x = size.width / 2 + scale * math.sin(t);
    final y = size.height / 2 + scale * math.sin(t) * math.cos(t);

    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), 8, pointPaint);
  }

  @override
  bool shouldRepaint(Figure8Painter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}