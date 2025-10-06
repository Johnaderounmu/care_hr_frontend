import 'dart:io';
import 'dart:typed_data';

/// A simple replacement for PlatformFile that works across all platforms
class CustomPlatformFile {
  final String name;
  final String? path;
  final int size;
  final String? extension;
  final Uint8List? bytes;

  const CustomPlatformFile({
    required this.name,
    this.path,
    required this.size,
    this.extension,
    this.bytes,
  });

  /// Create from File (for mobile platforms)
  static Future<CustomPlatformFile> fromFile(File file) async {
    final bytes = await file.readAsBytes();
    final stats = await file.stat();
    
    return CustomPlatformFile(
      name: file.path.split('/').last,
      path: file.path,
      size: stats.size,
      extension: file.path.split('.').last.toLowerCase(),
      bytes: bytes,
    );
  }

  /// Create from bytes (for web platforms)
  static CustomPlatformFile fromBytes({
    required String name,
    required Uint8List bytes,
    String? extension,
  }) {
    return CustomPlatformFile(
      name: name,
      path: null,
      size: bytes.length,
      extension: extension ?? name.split('.').last.toLowerCase(),
      bytes: bytes,
    );
  }
}