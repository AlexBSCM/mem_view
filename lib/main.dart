import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(home: StorageScreen(), debugShowCheckedModeBanner: false),
  );
}

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  double usedGB = 178.4;
  final double totalGB = 256.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ХРАНИЛИЩЕ',
          style: TextStyle(fontSize: 16, letterSpacing: 2, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildChart(),
            const SizedBox(height: 40),
            _buildActionCard(),
            const SizedBox(height: 40),
            _buildCategorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    double freeGB = totalGB - usedGB;
    double freePercent = freeGB / totalGB;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 260,
          height: 260,
          child: CircularProgressIndicator(
            value: freePercent,
            strokeWidth: 12,
            backgroundColor: const Color(0xFF1F1F26),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA78BFA)),
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
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const Text(
                'ГБ СВОБОДНО',
                style: TextStyle(
                  color: Color(0xFFA78BFA),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 50,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF131317),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2A2A32), width: 1.5),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.white),
                children: [
                  TextSpan(
                    text: 'Занято ${usedGB.toStringAsFixed(1)} ГБ ',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: 'из ${totalGB.toInt()} ГБ',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_fix_high, color: Color(0xFFA78BFA)),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Освободите место, удалив ненужное',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              if (usedGB > 50) usedGB -= 10.5;
            }),
            child: const Text(
              'ОЧИСТИТЬ',
              style: TextStyle(
                color: Color(0xFFA78BFA),
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
            color: Colors.grey,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 24),
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
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FilesScreen(categoryName: title),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  size,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
      ),
    );
  }
}

class FilesScreen extends StatelessWidget {
  final String categoryName;
  const FilesScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Явно задаем кнопку назад, чтобы она была белой
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context), // Команда возврата
        ),
        title: Text(
          categoryName.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Icon(Icons.folder_open, size: 80, color: Color(0xFF2A2A32)),
          ),
          const SizedBox(height: 16),
          Text(
            'Здесь будет список: $categoryName',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),
          // Кнопка возврата также внутри контента для удобства
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2A2A32)),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('ВЕРНУТЬСЯ НА ГЛАВНУЮ'),
          ),
        ],
      ),
    );
  }
}
