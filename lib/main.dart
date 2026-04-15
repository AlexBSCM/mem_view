import 'package:flutter/material.dart';

// --- КОНСТАНТЫ ЦВЕТОВ ---
class AppColors {
  static const Color background = Color(0xFF0E0E12);
  static const Color card = Color(0xFF1F1F26);
  static const Color accent = Color(0xFFA78BFA);
  static const Color video = Color(0xFFF472B6);
  static const Color photo = Color(0xFF60A5FA);
  static const Color apps = Color(0xFFA78BFA);
  static const Color audio = Color(0xFF34D399);
  static const Color docs = Color(0xFFFBBF24);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color border = Color(0xFF2A2A32);
}

void main() => runApp(const MemoryViewApp());

class MemoryViewApp extends StatelessWidget {
  const MemoryViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const StorageScreen(),
    );
  }
}

// --- ГЛАВНЫЙ ЭКРАН ---
class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  double usedGB = 168.4;
  final double totalGB = 256.0;

  @override
  Widget build(BuildContext context) {
    final double freeGB = totalGB - usedGB;
    final double progress = freeGB / totalGB;

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
            _buildRing(freeGB, progress),
            const SizedBox(height: 40),
            _buildActionCard(),
            const SizedBox(height: 40),
            _buildCategorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRing(double freeGB, double progress) {
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
            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
        Positioned(
          top: 75,
          child: Column(
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
            child: Text(
              'Занято ${usedGB.toStringAsFixed(1)} ГБ из ${totalGB.toInt()} ГБ',
              style: const TextStyle(fontSize: 12),
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
          const Icon(Icons.auto_fix_high, color: AppColors.accent),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Очистить временные файлы',
              style: TextStyle(fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              if (usedGB > 50) usedGB -= 5.5;
            }),
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
          ),
        ),
        const SizedBox(height: 16),
        _categoryItem('Видео', 82.4, AppColors.video, Icons.videocam_outlined),
        _categoryItem('Фото', 12.1, AppColors.photo, Icons.image_outlined),
        _categoryItem('Аудио', 4.2, AppColors.audio, Icons.audiotrack_outlined),
        _categoryItem('Приложения', 54.0, AppColors.apps, Icons.apps_outlined),
        _categoryItem(
          'Документы',
          1.8,
          AppColors.docs,
          Icons.description_outlined,
        ),
      ],
    );
  }

  Widget _categoryItem(String title, double value, Color color, IconData icon) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsScreen(category: title, color: color),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Text(title),
                const Spacer(),
                Text(
                  '${value.toStringAsFixed(1)} GB',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: value / totalGB,
              backgroundColor: AppColors.card,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ],
        ),
      ),
    );
  }
}

// --- ЭКРАН ДЕТАЛЕЙ С ЗАГЛУШКАМИ ФАЙЛОВ ---
class DetailsScreen extends StatefulWidget {
  final String category;
  final Color color;
  const DetailsScreen({super.key, required this.category, required this.color});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  // Имитация списка файлов (Этап 4)
  List<Map<String, String>> mockFiles = [
    {'name': 'Запись_экрана_01.mp4', 'size': '1.2 GB', 'date': '12 Апр 2026'},
    {'name': 'Фильм_в_поездку.mkv', 'size': '4.5 GB', 'date': '10 Апр 2026'},
    {'name': 'Презентация_проект.pdf', 'size': '24 MB', 'date': '08 Апр 2026'},
    {'name': 'Трек_05_избранное.mp3', 'size': '12 MB', 'date': '05 Апр 2026'},
    {'name': 'Фото_с_отпуска_01.jpg', 'size': '8 MB', 'date': '01 Апр 2026'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category.toUpperCase(),
          style: const TextStyle(fontSize: 14, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Краткая инфо-панель сверху
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.folder_open, color: widget.color, size: 40),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${mockFiles.length} файлов всего',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Отсортировано по размеру',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          // Список файлов (FileTile из Этапа 4)
          Expanded(
            child: ListView.separated(
              itemCount: mockFiles.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: AppColors.border, height: 1),
              itemBuilder: (context, index) {
                final file = mockFiles[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getFileIcon(widget.category),
                      color: widget.color,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    file['name']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '${file['date']} • ${file['size']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      // Имитация удаления для проверки интерактива
                      setState(() => mockFiles.removeAt(index));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Файл удален (имитация)')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String category) {
    switch (category) {
      case 'Видео':
        return Icons.play_circle_outline;
      case 'Фото':
        return Icons.image_outlined;
      case 'Аудио':
        return Icons.music_note_outlined;
      case 'Приложения':
        return Icons.extension_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }
}
