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

// Режимы отображения
enum ViewMode { smallGrid, largeGrid, list }

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
    }
  }

  double _calculateTotalUsedGB() {
    int totalBytes = 0;
    for (var f in foundVideos) totalBytes += f.lengthSync();
    for (var f in foundPhotos) totalBytes += f.lengthSync();
    return totalBytes / (1024 * 1024 * 1024);
  }

  @override
  Widget build(BuildContext context) {
    double usedGB = _calculateTotalUsedGB();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CircularProgressIndicator(
            value: (used / 50).clamp(0, 1),
            strokeWidth: 12,
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
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
            ),
            const Text(
              'ГБ НАЙДЕНО',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
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
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${files.length} объектов'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
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
  ViewMode _viewMode = ViewMode.smallGrid;

  @override
  void initState() {
    super.initState();
    currentFiles = List.from(widget.files);
  }

  void _toggleViewMode() {
    setState(() {
      if (_viewMode == ViewMode.smallGrid)
        _viewMode = ViewMode.largeGrid;
      else if (_viewMode == ViewMode.largeGrid)
        _viewMode = ViewMode.list;
      else
        _viewMode = ViewMode.smallGrid;
    });
  }

  IconData _getViewIcon() {
    if (_viewMode == ViewMode.smallGrid) return Icons.grid_view_rounded;
    if (_viewMode == ViewMode.largeGrid) return Icons.view_comfy_alt;
    return Icons.view_list_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title.toUpperCase(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_getViewIcon(), color: AppColors.accent),
            onPressed: _toggleViewMode,
          ),
        ],
      ),
      body: currentFiles.isEmpty
          ? const Center(child: Text("Пусто"))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_viewMode == ViewMode.list) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: currentFiles.length,
        itemBuilder: (context, index) => _buildListItem(currentFiles[index]),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _viewMode == ViewMode.smallGrid ? 3 : 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: _viewMode == ViewMode.smallGrid ? 0.8 : 0.75,
      ),
      itemCount: currentFiles.length,
      itemBuilder: (context, index) => _buildGridItem(currentFiles[index]),
    );
  }

  Widget _buildGridItem(File file) {
    return GestureDetector(
      onLongPress: () => _deleteFile(file),
      onTap: () => _showInfo(file.path),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: widget.title == 'Фото'
                    ? Image.file(
                        file,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : VideoThumbnailView(file: file, color: widget.color),
              ),
            ),
            if (_viewMode == ViewMode.largeGrid)
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  p.basename(file.path),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(File file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onLongPress: () => _deleteFile(file),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 50,
            height: 50,
            child: widget.title == 'Фото'
                ? Image.file(file, fit: BoxFit.cover)
                : VideoThumbnailView(file: file, color: widget.color),
          ),
        ),
        title: Text(
          p.basename(file.path),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
        subtitle: Text(
          "${(file.lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB",
          style: const TextStyle(fontSize: 11),
        ),
        trailing: const Icon(Icons.info_outline, size: 18),
        onTap: () => _showInfo(file.path),
      ),
    );
  }

  Future<void> _deleteFile(File file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text("Удалить?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text("НЕТ"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text("ДА", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await file.delete();
      setState(() => currentFiles.removeWhere((f) => f.path == file.path));
    }
  }

  void _showInfo(String path) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.card,
        content: Text(path, style: const TextStyle(fontSize: 11)),
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
        maxWidth: 150,
        quality: 20,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            width: double.infinity,
          );
        return Container(
          color: color.withOpacity(0.1),
          child: Center(
            child: Icon(Icons.play_circle_fill, color: color, size: 24),
          ),
        );
      },
    );
  }
}
