import 'package:flutter/material.dart';

// --- КОНСТАНТЫ ЦВЕТОВ (Архитектурный этап 1) ---
class AppColors {
  static const Color background = Color(0xFF0E0E12);
  static const Color card = Color(0xFF1F1F26);
  static const Color accent = Color(0xFFA78BFA); // Фиолетовый
  static const Color video = Color(0xFFF472B6); // Розовый
  static const Color photo = Color(0xFF60A5FA); // Голубой
  static const Color apps = Color(0xFFA78BFA); // Фиолетовый
  static const Color audio = Color(0xFF34D399); // Зеленый
  static const Color docs = Color(0xFFFBBF24); // Желтый
  static const Color other = Color(0xFF94A3B8); // Серый
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color border = Color(0xFF2A2A32);
}

void main() {
  runApp(const MemoryViewApp());
}

class MemoryViewApp extends StatelessWidget {
  const MemoryViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory View',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'sans-serif',
      ),
      home: const StorageScreen(),
    );
  }
}

// --- ГЛАВНЫЙ ЭКРАН (Архитектурный этап 3) ---
class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  // Данные (в будущем будут приходить из StorageRepository)
  double usedGB = 168.4;
  final double totalGB = 256.0;

  @override
  Widget build(BuildContext context) {
    final double freeGB = totalGB - usedGB;
    final double freeProgress = freeGB / totalGB;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ХРАНИЛИЩЕ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Центрированное кольцо (StorageRing)
            _buildStorageRing(freeGB, freeProgress),
            const SizedBox(height: 40),
            // Карточка быстрой очистки
            _buildActionCard(),
            const SizedBox(height: 40),
            // Секция категорий
            _buildCategorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageRing(double freeGB, double progress) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 260,
          height: 260,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 12,
            backgroundColor: AppColors.card,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
        ),
        Positioned(
          top: 75,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                freeGB.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 58,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
              const Text(
                'ГБ СВОБОДНО',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 55,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
                children: [
                  const TextSpan(text: 'Занято '),
                  TextSpan(
                    text: '${usedGB.toStringAsFixed(1)} ГБ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' из ${totalGB.toInt()} ГБ',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_fix_high, color: AppColors.accent, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Освободите место, удалив ненужное',
              style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (usedGB > 30) usedGB -= 12.5; // Эффект очистки
              });
            },
            child: const Text(
              'ОЧИСТИТЬ',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        _buildCategoryItem(
          'Видео',
          82.4,
          AppColors.video,
          Icons.videocam_outlined,
        ),
        _buildCategoryItem('Фото', 12.1, AppColors.photo, Icons.image_outlined),
        _buildCategoryItem(
          'Приложения',
          54.0,
          AppColors.apps,
          Icons.apps_outlined,
        ),
        _buildCategoryItem(
          'Аудио',
          4.2,
          AppColors.audio,
          Icons.audiotrack_outlined,
        ),
        _buildCategoryItem(
          'Прочее',
          15.7,
          AppColors.other,
          Icons.more_horiz_outlined,
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    String title,
    double value,
    Color color,
    IconData icon,
  ) {
    // Честный расчет прогресса относительно общего объема (Этап 3)
    final double progress = value / totalGB;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(category: title),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${value.toStringAsFixed(1)} GB',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 5,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ЭКРАН ДЕТАЛЕЙ (Заглушка для этапа 4) ---
class DetailsScreen extends StatelessWidget {
  final String category;
  const DetailsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          category.toUpperCase(),
          style: const TextStyle(fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: AppColors.card),
            const SizedBox(height: 16),
            Text(
              'Список файлов: $category',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
