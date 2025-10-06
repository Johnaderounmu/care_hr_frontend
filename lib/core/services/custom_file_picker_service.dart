import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../utils/custom_platform_file.dart';

class CustomFilePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Show a dialog to let user choose file selection method
  static Future<List<CustomPlatformFile>?> pickFiles({
    required BuildContext context,
    bool allowMultiple = false,
    List<String>? allowedExtensions,
  }) async {
    if (kIsWeb) {
      // For web, show a message that file upload is not yet supported
      _showUnsupportedMessage(context);
      return null;
    }

    // Show selection dialog
    final source = await _showFileSourceDialog(context);
    if (source == null) return null;

    try {
      switch (source) {
        case FileSource.camera:
          return await _pickFromCamera();
        case FileSource.gallery:
          return await _pickFromGallery(allowMultiple);
        case FileSource.documents:
          // For now, fallback to gallery for documents
          // In a full implementation, you could integrate with platform-specific document pickers
          _showDocumentMessage(context);
          return await _pickFromGallery(allowMultiple);
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
      return null;
    }
  }

  static Future<FileSource?> _showFileSourceDialog(BuildContext context) async {
    return showDialog<FileSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select File Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(FileSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Gallery'),
                onTap: () => Navigator.of(context).pop(FileSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Documents'),
                onTap: () => Navigator.of(context).pop(FileSource.documents),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  static Future<List<CustomPlatformFile>?> _pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      final file = File(image.path);
      final platformFile = await CustomPlatformFile.fromFile(file);
      return [platformFile];
    }
    return null;
  }

  static Future<List<CustomPlatformFile>?> _pickFromGallery(bool allowMultiple) async {
    if (allowMultiple) {
      final List<XFile> images = await _picker.pickMultipleMedia(
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final List<CustomPlatformFile> platformFiles = [];
        for (final image in images) {
          final file = File(image.path);
          final platformFile = await CustomPlatformFile.fromFile(file);
          platformFiles.add(platformFile);
        }
        return platformFiles;
      }
    } else {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final platformFile = await CustomPlatformFile.fromFile(file);
        return [platformFile];
      }
    }
    return null;
  }

  static void _showUnsupportedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File upload is not yet supported on web platform'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  static void _showDocumentMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document picker using photo gallery for now. PDF support coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

enum FileSource {
  camera,
  gallery,
  documents,
}