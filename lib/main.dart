import 'package:flutter/material.dart';
import 'dart:io';

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

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  // Начальные значения (заглушки, которые заменятся при инициализации)
  double usedGB = 0.0;
  double totalGB = 256.0; // По умолчанию для красоты
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStorageData();
  }

  // ЭТАП 2: Логика получения данных
  Future<void> _loadStorageData() async {
    // В реальном приложении здесь будет вызов platform-specific кода
    // Имитируем задержку чтения диска
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      usedGB = 142.8; // Здесь позже будет результат сканирования папок
      totalGB = 256.0;
      isLoading = false;
    });
  }

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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : SingleChildScrollView(
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
              'Анализ системы завершен',
              style: TextStyle(fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => _loadStorageData(), // Перезагрузка данных
            child: const Text(
              'ОБНОВИТЬ',
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

class DetailsScreen extends StatefulWidget {
  final String category;
  final Color color;
  const DetailsScreen({super.key, required this.category, required this.color});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool isSelectionMode = false;
  Set<int> selectedIndices = {};

  List<Map<String, String>> mockFiles = [
    {'name': 'Video_File_01.mp4', 'size': '1.2 GB', 'date': '12.04.2026'},
    {'name': 'Movie_2026.mkv', 'size': '4.5 GB', 'date': '10.04.2026'},
    {'name': 'Image_001.jpg', 'size': '4 MB', 'date': '09.04.2026'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isSelectionMode ? Icons.close : Icons.arrow_back_ios_new,
            size: 20,
          ),
          onPressed: () => isSelectionMode
              ? setState(() {
                  isSelectionMode = false;
                  selectedIndices.clear();
                })
              : Navigator.pop(context),
        ),
        title: Text(
          isSelectionMode
              ? 'ВЫБРАНО: ${selectedIndices.length}'
              : widget.category.toUpperCase(),
          style: const TextStyle(fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        itemCount: mockFiles.length,
        separatorBuilder: (context, index) =>
            const Divider(color: AppColors.border, height: 1),
        itemBuilder: (context, index) {
          final isSelected = selectedIndices.contains(index);
          return ListTile(
            onTap: isSelectionMode
                ? () => setState(
                    () => isSelected
                        ? selectedIndices.remove(index)
                        : selectedIndices.add(index),
                  )
                : null,
            leading: isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    activeColor: AppColors.accent,
                    onChanged: (v) => setState(
                      () => v!
                          ? selectedIndices.add(index)
                          : selectedIndices.remove(index),
                    ),
                  )
                : Icon(Icons.insert_drive_file, color: widget.color),
            title: Text(mockFiles[index]['name']!),
            subtitle: Text(mockFiles[index]['size']!),
            trailing: !isSelectionMode
                ? IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() => isSelectionMode = true),
                  )
                : null,
          );
        },
      ),
    );
  }
}
