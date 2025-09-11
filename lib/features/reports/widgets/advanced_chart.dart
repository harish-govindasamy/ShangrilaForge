import 'package:flutter/material.dart';
import 'dart:math' as math;

class AdvancedChart extends StatefulWidget {
  const AdvancedChart({super.key});

  @override
  State<AdvancedChart> createState() => _AdvancedChartState();
}

class _AdvancedChartState extends State<AdvancedChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive height based on screen width
        final chartHeight = constraints.maxWidth > 600 ? 400.0 : 320.0;

        return Container(
          height: chartHeight,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Performance Analytics',
                      style: TextStyle(
                        fontSize: constraints.maxWidth > 400 ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: _buildChartSelector(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _animation.value,
                      child: _selectedIndex == 0
                          ? _buildLineChart()
                          : _selectedIndex == 1
                              ? _buildBarChart()
                              : _buildPieChart(),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSelectorButton(0, Icons.show_chart, 'Line'),
              _buildSelectorButton(1, Icons.bar_chart, 'Bar'),
              _buildSelectorButton(2, Icons.pie_chart, 'Pie'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectorButton(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 200;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            _animationController.reset();
            _animationController.forward();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 8 : 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF667eea) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? Colors.white
                      : Colors.grey.withValues(alpha: 0.6),
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white
                          : Colors.grey.withValues(alpha: 0.6),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLineChart() {
    final data = [65.0, 80.0, 45.0, 90.0, 75.0, 30.0, 20.0];
    final maxValue = data.reduce(math.max);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            size: Size.infinite,
            painter: LineChartPainter(data, maxValue, _animation.value),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: days
              .map((day) => Text(
                    day,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final data = [75.0, 85.0, 65.0, 90.0];
    final labels = ['Q1', 'Q2', 'Q3', 'Q4'];
    final colors = [
      const Color(0xFF667eea),
      const Color(0xFF11998e),
      const Color(0xFFfc4a1a),
      const Color(0xFF764ba2),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = (constraints.maxWidth - 80) / data.length;
        final actualBarWidth = math.min(barWidth, 40).toDouble();

        return Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(data.length, (index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 500 + (index * 100)),
                    width: actualBarWidth,
                    height: (data[index] / 100) * 200 * _animation.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors[index],
                          colors[index].withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${data[index].toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: labels
                  .map((label) => Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ))
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPieChart() {
    final data = [35.0, 25.0, 20.0, 20.0];
    final colors = [
      const Color(0xFF667eea),
      const Color(0xFF11998e),
      const Color(0xFFfc4a1a),
      const Color(0xFF764ba2),
    ];
    final labels = ['Projects', 'Tasks', 'Reports', 'Others'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;

        if (isSmallScreen) {
          // Stack layout for small screens
          return Column(
            children: [
              Expanded(
                flex: 2,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: PieChartPainter(data, colors, _animation.value),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(data.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colors[index],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${labels[index]} (${data[index].toInt()}%)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        } else {
          // Row layout for larger screens
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: PieChartPainter(data, colors, _animation.value),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(data.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colors[index],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${labels[index]} (${data[index].toInt()}%)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;
  final double animationValue;

  LineChartPainter(this.data, this.maxValue, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF667eea)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF667eea).withValues(alpha: 0.3),
          const Color(0xFF667eea).withValues(alpha: 0.1),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final gradientPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y =
          size.height - (data[i] / maxValue) * size.height * animationValue;

      if (i == 0) {
        path.moveTo(x, y);
        gradientPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        gradientPath.lineTo(x, y);
      }

      // Draw dots
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()
          ..color = const Color(0xFF667eea)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Fill area under curve
    gradientPath.lineTo(size.width, size.height);
    gradientPath.lineTo(0, size.height);
    gradientPath.close();
    canvas.drawPath(gradientPath, gradientPaint);

    // Draw line
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class PieChartPainter extends CustomPainter {
  final List<double> data;
  final List<Color> colors;
  final double animationValue;

  PieChartPainter(this.data, this.colors, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

    double startAngle = -math.pi / 2;
    final total = data.reduce((a, b) => a + b);

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i] / total) * 2 * math.pi * animationValue;

      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw center circle
    canvas.drawCircle(
      center,
      radius * 0.4,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
