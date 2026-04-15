import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(const MemViewApp());

class MemViewApp extends StatelessWidget {
  const MemViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E0E12), // Твой фон
      ),
      // Стартуем с главного экрана "ХРАНИЛИЩЕ"
      home: const StorageScreen(),
    );
  }
}

// --- ЭКРАН 1: ГЛАВНОЕ ХРАНИЛИЩЕ ---
class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu),
        actions: const [Icon(Icons.settings_outlined), SizedBox(width: 16)],
        title: const Text(
          'ХРАНИЛИЩЕ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Text('Pixel 7 Pro', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            _buildChart(), // Тот самый сегментированный круг
            const SizedBox(height: 30),
            _buildActionCard(), // Кнопка "Очистить"
            const SizedBox(height: 30),
            _buildCategorySection(),
          ],
        ),
      ),
    );
  }

  // Виджет сегментированного чарта (код из предыдущего шага)
  Widget _buildChart() {
    return SizedBox(
      height: 200,
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: SegmentedChartPainter(),
          ),
          const Text(
            '178.4 GB',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ПО КАТЕГОРИЯМ',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildCategoryItem('Приложения', '54 GB', 0.6, const Color(0xFFA78BFA)),
        _buildCategoryItem(
          'Фото и видео',
          '82 GB',
          0.8,
          const Color(0xFFF472B6),
        ),
        _buildCategoryItem('Другое', '42 GB', 0.4, const Color(0xFFFBBF24)),
      ],
    );
  }

  Widget _buildCategoryItem(
    String title,
    String size,
    double progress,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Row(
            children: [
              // Квадратная плашка иконки
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF131317),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.grid_view_rounded, size: 20, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                size,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Прогресс-бар: СТРОГО БЕЗ СКРУГЛЕНИЙ
          Container(
            height: 6,
            width: double.infinity,
            color: const Color(0xFF2A2A32),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard() {
    /* Код кнопки очистки */
    return Container();
  }
}

// --- ЭКРАН 2: ДЕТАЛИЗАЦИЯ ПРИЛОЖЕНИЙ ---
class AppsDetailScreen extends StatelessWidget {
  const AppsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Приложения'), // Экран из первого билда
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildAppItem('Telegram', '12.4 GB', const Color(0xFFA78BFA)),
          _buildAppItem('Instagram', '8.2 GB', const Color(0xFFA78BFA)),
        ],
      ),
    );
  }

  Widget _buildAppItem(String name, String size, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131317),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.apps, color: color),
          const SizedBox(width: 16),
          Expanded(child: Text(name)),
          Text(size, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Тот самый Painter с четкими границами сегментов
class SegmentedChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.butt;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );

    paint.color = const Color(0xFFA78BFA); // Фиолетовый
    canvas.drawArc(rect, -math.pi / 2, 2.0, false, paint);

    paint.color = const Color(0xFFF472B6); // Розовый
    canvas.drawArc(rect, -math.pi / 2 + 2.0, 1.5, false, paint);

    paint.color = const Color(0xFFFBBF24); // Желтый
    canvas.drawArc(rect, -math.pi / 2 + 3.5, 0.7, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
