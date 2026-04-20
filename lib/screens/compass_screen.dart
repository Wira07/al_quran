import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/city_data.dart';
import '../utils/qibla_utils.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCity = 'Jakarta';
  double _qiblaAngle = 0;
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _loadCity();
  }

  Future<void> _loadCity() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCity = prefs.getString('city') ?? 'Jakarta';
    _updateQibla();
  }

  void _updateQibla() {
    final city = CityData.cities.firstWhere(
      (c) => c['name'] == _selectedCity,
      orElse: () => CityData.cities.first,
    );
    setState(() {
      _qiblaAngle = QiblaUtils.calculateQiblaDirection(
        city['lat'] as double,
        city['lon'] as double,
      );
    });
    _animController.forward(from: 0);
  }

  Future<void> _selectCity() async {
    final cities = CityData.cities.map((c) => c['name'] as String).toList();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.8,
          minChildSize: 0.3,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pilih Kota',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: cities.length,
                    itemBuilder: (_, i) {
                      final isSelected = cities[i] == _selectedCity;
                      return ListTile(
                        title: Text(cities[i]),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, cities[i]),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result != _selectedCity) {
      _selectedCity = result;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('city', _selectedCity);
      _updateQibla();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Arah Kiblat')),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _selectCity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedCity,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final animatedAngle = _qiblaAngle * _animation.value;
                    return SizedBox(
                      width: 280,
                      height: 280,
                      child: CustomPaint(
                        painter: _CompassPainter(
                          qiblaAngle: animatedAngle,
                          isDark: isDark,
                          primaryColor: theme.colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  '${_qiblaAngle.toStringAsFixed(1)}° dari Utara',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Arah Kiblat dari $_selectedCity',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Arahkan bagian atas HP ke utara, lalu hadap ke arah panah merah untuk menghadap kiblat.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double qiblaAngle;
  final bool isDark;
  final Color primaryColor;

  _CompassPainter({
    required this.qiblaAngle,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F0E8)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = primaryColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Inner decorative circle
    canvas.drawCircle(
      center,
      radius * 0.85,
      Paint()
        ..color = primaryColor.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Tick marks
    for (int i = 0; i < 360; i += 5) {
      final angle = i * pi / 180;
      final isMain = i % 90 == 0;
      final isMedium = i % 30 == 0;
      final startR = isMain
          ? radius * 0.72
          : (isMedium ? radius * 0.78 : radius * 0.82);
      final endR = radius * 0.88;

      canvas.drawLine(
        Offset(
          center.dx + startR * sin(angle),
          center.dy - startR * cos(angle),
        ),
        Offset(center.dx + endR * sin(angle), center.dy - endR * cos(angle)),
        Paint()
          ..color = isMain
              ? primaryColor
              : (isMedium
                    ? (isDark ? Colors.white38 : Colors.black38)
                    : (isDark ? Colors.white12 : Colors.black12))
          ..strokeWidth = isMain ? 3 : (isMedium ? 2 : 1)
          ..strokeCap = StrokeCap.round,
      );
    }

    // Cardinal directions
    _drawText(canvas, 'U', center, radius * 0.62, 0, primaryColor, 18);
    _drawText(
      canvas,
      'T',
      center,
      radius * 0.62,
      90,
      isDark ? Colors.white60 : Colors.black54,
      14,
    );
    _drawText(
      canvas,
      'S',
      center,
      radius * 0.62,
      180,
      isDark ? Colors.white60 : Colors.black54,
      14,
    );
    _drawText(
      canvas,
      'B',
      center,
      radius * 0.62,
      270,
      isDark ? Colors.white60 : Colors.black54,
      14,
    );

    // Qibla arrow
    final qiblaRad = qiblaAngle * pi / 180;
    final arrowLength = radius * 0.5;
    final arrowEnd = Offset(
      center.dx + arrowLength * sin(qiblaRad),
      center.dy - arrowLength * cos(qiblaRad),
    );

    // Arrow shaft
    canvas.drawLine(
      center,
      arrowEnd,
      Paint()
        ..color = primaryColor
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Arrow head
    final headAngle = 25 * pi / 180;
    final headLen = 20.0;
    final arrowAngle = atan2(arrowEnd.dy - center.dy, arrowEnd.dx - center.dx);

    final path = Path()
      ..moveTo(arrowEnd.dx, arrowEnd.dy)
      ..lineTo(
        arrowEnd.dx - headLen * cos(arrowAngle - headAngle),
        arrowEnd.dy - headLen * sin(arrowAngle - headAngle),
      )
      ..lineTo(
        arrowEnd.dx - headLen * cos(arrowAngle + headAngle),
        arrowEnd.dy - headLen * sin(arrowAngle + headAngle),
      )
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill,
    );

    // Center Kaaba icon (decorative square)
    final kaabaSize = 12.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: kaabaSize * 2,
          height: kaabaSize * 2,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = primaryColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: kaabaSize * 2,
          height: kaabaSize * 2,
        ),
        const Radius.circular(3),
      ),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    double distance,
    double angle,
    Color color,
    double fontSize,
  ) {
    final rad = angle * pi / 180;
    final pos = Offset(
      center.dx + distance * sin(rad),
      center.dy - distance * cos(rad),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      pos - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _CompassPainter old) =>
      old.qiblaAngle != qiblaAngle || old.isDark != isDark;
}
