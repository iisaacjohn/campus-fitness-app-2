import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dart:math';

class ChartPlaceholder extends StatelessWidget {
  final String title;
  final double height;
  final ChartType type;
  
  const ChartPlaceholder({
    Key? key,
    required this.title,
    this.height = 200,
    this.type = ChartType.bar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightGreen.withOpacity(0.5)),
          ),
          child: type == ChartType.bar ? _buildBarChart() : _buildLineChart(),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final random = Random();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final height = 30 + random.nextInt(100);
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 24,
                height: height.toDouble(),
                decoration: BoxDecoration(
                  color: index % 2 == 0 ? AppColors.primaryGreen : AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLineChart() {
    return CustomPaint(
      painter: LineChartPainter(),
      size: Size.infinite,
    );
  }
}

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final dotPaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.fill;
    
    final random = Random();
    final points = List.generate(7, (index) {
      return Offset(
        size.width * (index + 1) / 8,
        size.height * (0.2 + random.nextDouble() * 0.6),
      );
    });
    
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    canvas.drawPath(path, paint);
    
    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum ChartType { bar, line }
