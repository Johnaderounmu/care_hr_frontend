import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';

class AdvancedFileUploadWidget extends StatefulWidget {
  final List<String> allowedExtensions;
  final int maxFileSize; // in MB
  final int maxFiles;
  final bool allowMultiple;
  final bool showPreview;
  final Function(List<UploadedFile>) onFilesSelected;
  final Function(List<UploadedFile>)? onUploadComplete;
  final String uploadEndpoint;
  final String title;
  final String subtitle;

  const AdvancedFileUploadWidget({
    super.key,
    this.allowedExtensions = const ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    this.maxFileSize = 10, // 10MB
    this.maxFiles = 5,
    this.allowMultiple = true,
    this.showPreview = true,
    required this.onFilesSelected,
    this.onUploadComplete,
    this.uploadEndpoint = '/api/upload',
    this.title = 'Upload Documents',
    this.subtitle = 'Select files to upload',
  });

  @override
  State<AdvancedFileUploadWidget> createState() => _AdvancedFileUploadWidgetState();
}

class _AdvancedFileUploadWidgetState extends State<AdvancedFileUploadWidget>
    with TickerProviderStateMixin {
  final List<UploadedFile> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  double _overallProgress = 0.0;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectFiles() async {
    try {
      if (widget.allowMultiple) {
        final List<XFile> files = await _picker.pickMultipleMedia(
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        await _processSelectedFiles(files);
      } else {
        final XFile? file = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        if (file != null) {
          await _processSelectedFiles([file]);
        }
      }
    } catch (e) {
      _showErrorSnackbar('Error selecting files: $e');
    }
  }

  Future<void> _selectCamera() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (file != null) {
        await _processSelectedFiles([file]);
      }
    } catch (e) {
      _showErrorSnackbar('Error taking photo: $e');
    }
  }

  Future<void> _selectDocuments() async {
    // Note: For document selection, you might want to use file_picker package
    // For now, this is a placeholder
    _showInfoDialog(
      'Document Selection',
      'Document selection will be available in the next update. For now, please use the gallery option for images.',
    );
  }

  Future<void> _processSelectedFiles(List<XFile> files) async {
    final List<UploadedFile> validFiles = [];
    
    for (final file in files) {
      // Check file count limit
      if (_selectedFiles.length + validFiles.length >= widget.maxFiles) {
        _showErrorSnackbar('Maximum ${widget.maxFiles} files allowed');
        break;
      }
      
      // Get file info
      final int fileSize = await file.length();
      final String extension = file.path.split('.').last.toLowerCase();
      
      // Validate file extension
      if (!widget.allowedExtensions.contains(extension)) {
        _showErrorSnackbar(
          'File ${file.name} has unsupported format. Allowed: ${widget.allowedExtensions.join(', ')}',
        );
        continue;
      }
      
      // Validate file size
      final double fileSizeMB = fileSize / (1024 * 1024);
      if (fileSizeMB > widget.maxFileSize) {
        _showErrorSnackbar(
          'File ${file.name} is too large. Maximum size: ${widget.maxFileSize}MB',
        );
        continue;
      }
      
      // Create uploaded file object
      final uploadedFile = UploadedFile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: file.name,
        path: file.path,
        size: fileSize,
        extension: extension,
        uploadProgress: 0.0,
        status: FileUploadStatus.selected,
        thumbnail: await _generateThumbnail(file),
      );
      
      validFiles.add(uploadedFile);
    }
    
    setState(() {
      _selectedFiles.addAll(validFiles);
    });
    
    widget.onFilesSelected(_selectedFiles);
    
    if (validFiles.isNotEmpty) {
      _animateSelection();
    }
  }

  Future<Uint8List?> _generateThumbnail(XFile file) async {
    try {
      if (_isImage(file.path)) {
        final bytes = await file.readAsBytes();
        // For a real app, you might want to resize the image here
        return bytes.length > 50000 ? null : bytes; // Return null for large images to save memory
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  bool _isImage(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  void _animateSelection() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles.isEmpty) return;
    
    setState(() {
      _isUploading = true;
      _overallProgress = 0.0;
    });
    
    try {
      for (int i = 0; i < _selectedFiles.length; i++) {
        final file = _selectedFiles[i];
        
        setState(() {
          file.status = FileUploadStatus.uploading;
        });
        
        // Simulate upload progress
        await _uploadSingleFile(file, (progress) {
          setState(() {
            file.uploadProgress = progress;
            _overallProgress = (_selectedFiles
                .map((f) => f.uploadProgress)
                .reduce((a, b) => a + b)) / _selectedFiles.length;
          });
        });
        
        setState(() {
          file.status = FileUploadStatus.completed;
        });
      }
      
      _showSuccessSnackbar('All files uploaded successfully!');
      widget.onUploadComplete?.call(_selectedFiles);
      
    } catch (e) {
      _showErrorSnackbar('Upload failed: $e');
      // Mark failed files
      for (final file in _selectedFiles) {
        if (file.status == FileUploadStatus.uploading) {
          file.status = FileUploadStatus.failed;
        }
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _uploadSingleFile(
    UploadedFile file,
    Function(double) onProgress,
  ) async {
    try {
      // Simulate upload with progress
      for (double progress = 0.0; progress <= 1.0; progress += 0.1) {
        await Future.delayed(const Duration(milliseconds: 200));
        onProgress(progress);
      }
      
      // TODO: Implement actual upload to server
      // final request = http.MultipartRequest('POST', Uri.parse(widget.uploadEndpoint));
      // final multipartFile = await http.MultipartFile.fromPath('file', file.path);
      // request.files.add(multipartFile);
      
      print('File ${file.name} uploaded successfully');
    } catch (e) {
      throw Exception('Failed to upload ${file.name}: $e');
    }
  }

  void _removeFile(String fileId) {
    setState(() {
      _selectedFiles.removeWhere((file) => file.id == fileId);
    });
    widget.onFilesSelected(_selectedFiles);
  }

  void _clearAllFiles() {
    setState(() {
      _selectedFiles.clear();
    });
    widget.onFilesSelected(_selectedFiles);
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        
        // Upload area
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primary.withOpacity(0.05),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedFiles.isEmpty 
                          ? 'Choose files or drag and drop them here'
                          : '${_selectedFiles.length} file(s) selected',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Supported formats: ${widget.allowedExtensions.join(', ').toUpperCase()}\n'
                      'Maximum size: ${widget.maxFileSize}MB per file\n'
                      'Maximum files: ${widget.maxFiles}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Selection buttons
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _selectFiles,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _selectCamera,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _selectDocuments,
                          icon: const Icon(Icons.description),
                          label: const Text('Documents'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentInfo,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // Selected files list
        if (_selectedFiles.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Files (${_selectedFiles.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _clearAllFiles,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          ...List.generate(_selectedFiles.length, (index) {
            return _FilePreviewCard(
              file: _selectedFiles[index],
              onRemove: () => _removeFile(_selectedFiles[index].id),
              showPreview: widget.showPreview,
            );
          }),
          
          const SizedBox(height: 24),
          
          // Upload progress
          if (_isUploading) ...[
            Text(
              'Uploading files...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _overallProgress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              '${(_overallProgress * 100).toInt()}% complete',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
          ],
          
          // Upload button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadFiles,
              icon: _isUploading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.upload),
              label: Text(_isUploading ? 'Uploading...' : 'Upload Files'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FilePreviewCard extends StatelessWidget {
  final UploadedFile file;
  final VoidCallback onRemove;
  final bool showPreview;

  const _FilePreviewCard({
    required this.file,
    required this.onRemove,
    required this.showPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // File icon/thumbnail
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getFileColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: showPreview && file.thumbnail != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        file.thumbnail!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      _getFileIcon(),
                      color: _getFileColor(),
                      size: 24,
                    ),
            ),
            
            const SizedBox(width: 12),
            
            // File info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatFileSize(file.size)} • ${file.extension.toUpperCase()}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Status and progress
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(),
                        size: 12,
                        color: _getStatusColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (file.status == FileUploadStatus.uploading) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${(file.uploadProgress * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  if (file.status == FileUploadStatus.uploading)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: LinearProgressIndicator(
                        value: file.uploadProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 2,
                      ),
                    ),
                ],
              ),
            ),
            
            // Remove button
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 18),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon() {
    switch (file.extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor() {
    switch (file.extension.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (file.status) {
      case FileUploadStatus.selected:
        return Icons.schedule;
      case FileUploadStatus.uploading:
        return Icons.upload;
      case FileUploadStatus.completed:
        return Icons.check_circle;
      case FileUploadStatus.failed:
        return Icons.error;
    }
  }

  Color _getStatusColor() {
    switch (file.status) {
      case FileUploadStatus.selected:
        return Colors.orange;
      case FileUploadStatus.uploading:
        return AppColors.primary;
      case FileUploadStatus.completed:
        return AppColors.success;
      case FileUploadStatus.failed:
        return AppColors.error;
    }
  }

  String _getStatusText() {
    switch (file.status) {
      case FileUploadStatus.selected:
        return 'Ready to upload';
      case FileUploadStatus.uploading:
        return 'Uploading...';
      case FileUploadStatus.completed:
        return 'Uploaded';
      case FileUploadStatus.failed:
        return 'Failed';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class UploadedFile {
  final String id;
  final String name;
  final String path;
  final int size;
  final String extension;
  final Uint8List? thumbnail;
  double uploadProgress;
  FileUploadStatus status;

  UploadedFile({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.extension,
    this.thumbnail,
    this.uploadProgress = 0.0,
    this.status = FileUploadStatus.selected,
  });
}

enum FileUploadStatus {
  selected,
  uploading,
  completed,
  failed,
}