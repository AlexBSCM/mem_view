import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:video_thumbnail/video_thumbnail.dart';

// --- КОНСТАНТЫ СТИЛЯ ---
class AppColors {
  static const Color background = Color(0xFF0E0E12);
  static const Color card = Color(0xFF1F1F26);
  static const Color accent = Color(0xFFA78BFA);
  static const Color video = Color(0xFFF472B6);
  static const Color photo = Color(0xFF60A5FA);
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
        useMaterial3: true,
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
  List<File> foundVideos = [];
  List<File> foundPhotos = [];
  bool isScanning = false;
  final double totalGB = 256.0;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndScan();
  }

  Future<void> _requestPermissionsAndScan() async {
    if (Platform.isAndroid) {
      await Permission.manageExternalStorage.request();
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        await [Permission.photos, Permission.videos].request();
      } else {
        await Permission.storage.request();
      }
    }
    await _performFileScan();
  }

  Future<void> _performFileScan() async {
    if (!mounted) return;
    setState(() => isScanning = true);

    List<File> vids = [];
    List<File> pics = [];
    List<String> paths = [
      '/storage/emulated/0/Download',
      '/storage/emulated/0/DCIM/Camera',
      '/storage/emulated/0/Pictures',
      '/storage/emulated/0/Movies',
    ];

    try {
      for (var path in paths) {
        final dir = Directory(path);
        if (await dir.exists()) {
          final entities = dir.listSync(recursive: false);
          for (var e in entities) {
            if (e is File) {
              final ext = p.extension(e.path).toLowerCase();
              if (['.mp4', '.mkv', '.mov', '.3gp'].contains(ext)) vids.add(e);
              if (['.jpg', '.jpeg', '.png', '.webp', '.heic'].contains(ext))
                pics.add(e);
            }
          }
        }
      }

      vids.sort((a, b) => b.lengthSync().compareTo(a.lengthSync()));
      pics.sort((a, b) => b.lengthSync().compareTo(a.lengthSync()));

      if (mounted) {
        setState(() {
          foundVideos = vids;
          foundPhotos = pics;
          isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isScanning = false);
      debugPrint("Scan Error: $e");
    }
  }

  double _calculateTotalUsedGB() {
    int totalBytes = 0;
    for (var f in foundVideos) {
      totalBytes += f.lengthSync();
    }
    for (var f in foundPhotos) {
      totalBytes += f.lengthSync();
    }
    return totalBytes / (1024 * 1024 * 1024);
  }

  @override
  Widget build(BuildContext context) {
    double usedGB = _calculateTotalUsedGB();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'MEM VIEW',
          style: TextStyle(
            letterSpacing: 4,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _performFileScan,
        color: AppColors.accent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProgressRing(usedGB),
              const SizedBox(height: 40),
              _categoryCard(
                'Видео',
                foundVideos,
                AppColors.video,
                Icons.videocam_outlined,
              ),
              const SizedBox(height: 16),
              _categoryCard(
                'Фото',
                foundPhotos,
                AppColors.photo,
                Icons.image_outlined,
              ),
              if (isScanning)
                const Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRing(double used) {
    double percent = (used / 50.0).clamp(0.0, 1.0);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: CircularProgressIndicator(
            value: percent,
            strokeWidth: 15,
            backgroundColor: AppColors.card,
            color: AppColors.accent,
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              used.toStringAsFixed(1),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const Text(
              'ГБ НАЙДЕНО',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _categoryCard(
    String title,
    List<File> files,
    Color color,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) =>
                  DetailsScreen(title: title, color: color, files: files),
            ),
          );
          _performFileScan();
        },
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${files.length} объектов',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class DetailsScreen extends StatefulWidget {
  final String title;
  final Color color;
  final List<File> files;

  const DetailsScreen({
    super.key,
    required this.title,
    required this.color,
    required this.files,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late List<File> currentFiles;

  @override
  void initState() {
    super.initState();
    currentFiles = List.from(widget.files);
  }

  String _formatSize(int bytes) {
    if (bytes > 1024 * 1024 * 1024)
      return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  Future<void> _deleteFile(File file) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text("Удалить файл?"),
          content: const Text("Это действие нельзя будет отменить."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text("ОТМЕНА"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text("УДАЛИТЬ", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await file.delete();
        setState(() {
          currentFiles.removeWhere((f) => f.path == file.path);
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Файл успешно удален")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ошибка удаления: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title.toUpperCase(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
      ),
      body: currentFiles.isEmpty
          ? const Center(child: Text("Папка пуста"))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: currentFiles.length,
              itemBuilder: (context, index) {
                final file = currentFiles[index];
                final folder = file.parent.path.split('/').last;
                final fileName = p.basename(file.path);

                return GestureDetector(
                  onLongPress: () => _deleteFile(file),
                  onTap: () => _showInfo(file.path),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: widget.title == 'Фото'
                                ? Image.file(
                                    file,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : VideoThumbnailView(
                                    file: file,
                                    color: widget.color,
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                folder.toUpperCase(),
                                style: TextStyle(
                                  color: widget.color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _formatSize(file.lengthSync()),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showInfo(String path) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text("Расположение файла", style: TextStyle(fontSize: 16)),
        content: Text(
          path,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("ОК"),
          ),
        ],
      ),
    );
  }
}

class VideoThumbnailView extends StatelessWidget {
  final File file;
  final Color color;

  const VideoThumbnailView({
    super.key,
    required this.file,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: VideoThumbnail.thumbnailData(
        video: file.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 200,
        quality: 30,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            width: double.infinity,
          );
        }
        return Container(
          color: color.withOpacity(0.1),
          child: Center(
            child: Icon(Icons.play_circle_fill, color: color, size: 40),
          ),
        );
      },
    );
  }
}
