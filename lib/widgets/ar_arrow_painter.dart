// =====================================================
// 🎨 AR ARROW PAINTER - FLECHA 3D ROJA
// =====================================================
// Dibuja flecha 3D con efectos de profundidad,
// sombras y animaciones
// =====================================================

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ArArrowPainter extends CustomPainter {
  // Datos de orientación
  final double compassHeading;
  final double pitch;
  final double roll;

  // Datos de navegación
  final double currentLat;
  final double currentLon;
  final double targetLat;
  final double targetLon;

  final double distanceToTarget;
  final double bearingToTarget;
  final double relativeAngle;

  // Animaciones
  final double pulseScale;
  final double rotationAngle;

  // Configuración visual
  final Color arrowColor;
  final bool isCalibrated;

  ArArrowPainter({
    required this.compassHeading,
    required this.pitch,
    required this.roll,
    required this.currentLat,
    required this.currentLon,
    required this.targetLat,
    required this.targetLon,
    required this.distanceToTarget,
    required this.bearingToTarget,
    required this.relativeAngle,
    required this.pulseScale,
    required this.rotationAngle,
    required this.arrowColor,
    required this.isCalibrated,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isCalibrated) {
      _drawCalibrationWarning(canvas, size);
      return;
    }

    // Verificar si el objetivo está en el campo de visión
    if (relativeAngle.abs() > 75) {
      _drawOffScreenIndicator(canvas, size);
      return;
    }

    // Calcular posición 3D proyectada
    final arrowPosition = _calculateArrowPosition(size);

    // Dibujar flecha 3D con efectos
    _draw3DArrow(canvas, arrowPosition, size);

    // Dibujar distancia
    _drawDistanceLabel(canvas, arrowPosition);
  }

  // =====================================================
  // 🎯 CALCULAR POSICIÓN DE FLECHA EN PANTALLA
  // =====================================================
  Offset _calculateArrowPosition(Size size) {
    // Ajustar posición horizontal según ángulo relativo
    final horizontalOffset = size.width / 2 + 
        (math.sin(_toRadians(relativeAngle)) * size.width * 0.35);

    // Ajustar posición vertical según distancia y pitch
    double verticalBase = size.height * 0.55;

    // Efecto de perspectiva: más cerca = más abajo
    final perspectiveOffset = (100 / (distanceToTarget + 10)).clamp(0, 50);

    // Ajustar por inclinación del dispositivo (pitch)
    final pitchAdjustment = pitch * 3;

    final verticalOffset = verticalBase + perspectiveOffset - pitchAdjustment;

    return Offset(horizontalOffset, verticalOffset);
  }

  // =====================================================
  // 🎨 DIBUJAR FLECHA 3D ROJA CON EFECTOS
  // =====================================================
  void _draw3DArrow(Canvas canvas, Offset position, Size size) {
    canvas.save();
    canvas.translate(position.dx, position.dy);

    // Aplicar rotación y escala
    canvas.rotate(_toRadians(relativeAngle));
    canvas.scale(pulseScale);

    // Escala según distancia (perspectiva)
    final distanceScale = _calculateDistanceScale();
    canvas.scale(distanceScale);

    // Tamaño base de la flecha
    final arrowSize = 80.0;

    // =====================================================
    // 🌑 SOMBRA 3D (PROFUNDIDAD)
    // =====================================================
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final shadowOffset = const Offset(6, 6);
    _drawArrowShape(canvas, arrowSize, shadowPaint, shadowOffset);

    // =====================================================
    // 🔴 CUERPO PRINCIPAL DE LA FLECHA (ROJO)
    // =====================================================
    final bodyPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(-arrowSize / 4, 0),
        Offset(arrowSize / 4, 0),
        [
          arrowColor.withOpacity(0.8),
          arrowColor,
          arrowColor.withOpacity(0.8),
        ],
        [0.0, 0.5, 1.0],
      )
      ..style = PaintingStyle.fill;

    _drawArrowShape(canvas, arrowSize, bodyPaint, Offset.zero);

    // =====================================================
    // ✨ BORDE BLANCO (CONTRASTE)
    // =====================================================
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;

    _drawArrowShape(canvas, arrowSize, borderPaint, Offset.zero);

    // =====================================================
    // 💫 EFECTO DE BRILLO (HIGHLIGHT)
    // =====================================================
    final highlightPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, -arrowSize * 0.8),
        Offset(0, -arrowSize * 0.4),
        [
          Colors.white.withOpacity(0.6),
          Colors.transparent,
        ],
      )
      ..style = PaintingStyle.fill;

    final highlightPath = Path()
      ..moveTo(0, -arrowSize * 0.9)
      ..lineTo(-arrowSize * 0.15, -arrowSize * 0.5)
      ..lineTo(arrowSize * 0.15, -arrowSize * 0.5)
      ..close();

    canvas.drawPath(highlightPath, highlightPaint);

    canvas.restore();
  }

  // =====================================================
  // 📐 FORMA DE LA FLECHA
  // =====================================================
  void _drawArrowShape(Canvas canvas, double size, Paint paint, Offset offset) {
    final path = Path();

    // Punta triangular superior
    path.moveTo(0 + offset.dx, -size + offset.dy);
    path.lineTo(-size * 0.5 + offset.dx, -size * 0.5 + offset.dy);
    path.lineTo(-size * 0.2 + offset.dx, -size * 0.5 + offset.dy);

    // Cuerpo rectangular
    path.lineTo(-size * 0.2 + offset.dx, size * 0.3 + offset.dy);
    path.lineTo(size * 0.2 + offset.dx, size * 0.3 + offset.dy);

    // Lado derecho
    path.lineTo(size * 0.2 + offset.dx, -size * 0.5 + offset.dy);
    path.lineTo(size * 0.5 + offset.dx, -size * 0.5 + offset.dy);
    path.close();

    // Dibujar con efecto 3D (bisel)
    if (paint.style == PaintingStyle.fill) {
      // Lado izquierdo más oscuro
      final leftShadePaint = Paint()
        ..color = arrowColor.withOpacity(0.5)
        ..style = PaintingStyle.fill;

      final leftShadePath = Path()
        ..moveTo(-size * 0.2 + offset.dx, -size * 0.5 + offset.dy)
        ..lineTo(-size * 0.5 + offset.dx, -size * 0.5 + offset.dy)
        ..lineTo(0 + offset.dx, -size + offset.dy)
        ..close();

      canvas.drawPath(leftShadePath, leftShadePaint);
    }

    canvas.drawPath(path, paint);
  }

  // =====================================================
  // 📏 CALCULAR ESCALA POR DISTANCIA
  // =====================================================
  double _calculateDistanceScale() {
    // Más grande cuando está cerca, más pequeño cuando está lejos
    if (distanceToTarget < 10) return 1.3;
    if (distanceToTarget < 30) return 1.1;
    if (distanceToTarget < 50) return 1.0;
    if (distanceToTarget < 100) return 0.9;
    return 0.8;
  }

  // =====================================================
  // 🏷️ ETIQUETA DE DISTANCIA
  // =====================================================
  void _drawDistanceLabel(Canvas canvas, Offset position) {
    final distanceText = distanceToTarget < 1000
        ? '${distanceToTarget.toStringAsFixed(0)} m'
        : '${(distanceToTarget / 1000).toStringAsFixed(1)} km';

    final textSpan = TextSpan(
      text: distanceText,
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 8,
          ),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy + 60,
      ),
    );
  }

  // =====================================================
  // ⚠️ INDICADOR FUERA DE PANTALLA
  // =====================================================
  void _drawOffScreenIndicator(Canvas canvas, Size size) {
    final indicatorPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Posición en el borde según el ángulo
    final isLeft = relativeAngle < 0;
    final edgeX = isLeft ? 60.0 : size.width - 60;
    final edgeY = size.height / 2;

    canvas.save();
    canvas.translate(edgeX, edgeY);
    canvas.rotate(_toRadians(isLeft ? -90 : 90));

    // Triángulo indicador
    final indicatorPath = Path()
      ..moveTo(0, -25)
      ..lineTo(-20, 15)
      ..lineTo(20, 15)
      ..close();

    canvas.drawPath(indicatorPath, indicatorPaint);
    canvas.drawPath(indicatorPath, borderPaint);

    canvas.restore();

    // Texto de distancia
    final textSpan = TextSpan(
      text: '${distanceToTarget.toStringAsFixed(0)} m',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(edgeX - textPainter.width / 2, edgeY + 30),
    );
  }

  // =====================================================
  // ⚠️ ADVERTENCIA DE CALIBRACIÓN
  // =====================================================
  void _drawCalibrationWarning(Canvas canvas, Size size) {
    final warningPaint = Paint()
      ..color = Colors.orange.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.8,
        height: 120,
      ),
      const Radius.circular(16),
    );

    canvas.drawRRect(rect, warningPaint);

    // Texto
    final textSpan = TextSpan(
      text: '⚠️ Calibración necesaria\nMueve el dispositivo en forma de 8',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 1.5,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(maxWidth: size.width * 0.7);
    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.width / 2,
        size.height / 2 - textPainter.height / 2,
      ),
    );
  }

  // =====================================================
  // 🔧 UTILIDADES
  // =====================================================
  double _toRadians(double degrees) => degrees * math.pi / 180;

  @override
  bool shouldRepaint(ArArrowPainter oldDelegate) {
    return compassHeading != oldDelegate.compassHeading ||
        pitch != oldDelegate.pitch ||
        relativeAngle != oldDelegate.relativeAngle ||
        distanceToTarget != oldDelegate.distanceToTarget ||
        pulseScale != oldDelegate.pulseScale;
  }
}