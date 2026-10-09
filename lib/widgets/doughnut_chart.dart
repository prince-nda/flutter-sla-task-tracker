import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_theme.dart';

/// Doughnut chart of SLA status counts, drawn with CustomPainter.
class DoughnutChart extends StatelessWidget {
  final Map<SlaStatus, int> counts;
  final double size;
  const DoughnutChart({super.key, required this.counts, this.size = 130});

  @override
  Widget build(BuildContext context) {
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _DoughnutPainter(counts, total),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$total',
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold)),
              const Text('Tasks', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoughnutPainter extends CustomPainter {
  final Map<SlaStatus, int> counts;
  final int total;
  _DoughnutPainter(this.counts, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.18;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    if (total == 0) {
      paint.color = AppColors.mist;
      canvas.drawArc(rect, 0, math.pi * 2, false, paint);
      return;
    }

    var start = -math.pi / 2;
    for (final status in SlaStatus.values) {
      final count = counts[status] ?? 0;
      if (count == 0) continue;
      final sweep = count / total * math.pi * 2;
      paint.color = AppColors.forSla(status);
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DoughnutPainter old) =>
      old.counts != counts || old.total != total;
}