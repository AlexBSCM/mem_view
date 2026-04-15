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
            // Список категорий
            _buildCategoryRow(
              context,
              title: 'Приложения',
              size: '54 GB',
              color: const Color(0xFFA78BFA),
              onTap: () {
                // ПЕРЕХОД НА ВТОРОЙ ЭКРАН
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppsDetailScreen(),
                  ),
                );
              },
            ),
            _buildCategoryRow(
              context,
              title: 'Фото и видео',
              size: '82 GB',
              color: const Color(0xFFF472B6),
            ),
            _buildCategoryRow(
              context,
              title: 'Другое',
              size: '42 GB',
              color: const Color(0xFFFBBF24),
            ),
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

  Widget _buildCategoryRow(
    BuildContext context, {
    required String title,
    required String size,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131317),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
            Text(size, style: const TextStyle(color: Colors.grey)),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
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
