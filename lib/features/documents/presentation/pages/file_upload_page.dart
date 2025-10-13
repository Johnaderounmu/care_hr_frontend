import 'package:flutter/material.dart';
import '../../../../core/widgets/advanced_file_upload_widget.dart';

class FileUploadPage extends StatefulWidget {
  const FileUploadPage({super.key});

  @override
  State<FileUploadPage> createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  List<UploadedFile> _uploadedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Upload'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Application Upload Example
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AdvancedFileUploadWidget(
                  title: 'Job Application Documents',
                  subtitle: 'Upload your resume, cover letter, and supporting documents',
                  allowedExtensions: const ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
                  maxFileSize: 10, // 10MB
                  maxFiles: 5,
                  allowMultiple: true,
                  showPreview: true,
                  uploadEndpoint: '/api/job-application/upload',
                  onFilesSelected: (files) {
                    setState(() {
                      _uploadedFiles = files;
                    });
                  },
                  onUploadComplete: (files) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All documents uploaded successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Profile Photo Upload Example
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AdvancedFileUploadWidget(
                  title: 'Profile Photo',
                  subtitle: 'Upload your professional headshot',
                  allowedExtensions: const ['jpg', 'jpeg', 'png'],
                  maxFileSize: 5, // 5MB
                  maxFiles: 1,
                  allowMultiple: false,
                  showPreview: true,
                  uploadEndpoint: '/api/profile/photo',
                  onFilesSelected: (files) {
                    // Handle single profile photo
                    print('Profile photo selected: ${files.isNotEmpty ? files.first.name : 'None'}');
                  },
                  onUploadComplete: (files) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile photo updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Upload Summary
            if (_uploadedFiles.isNotEmpty) ...[
              const Text(
                'Upload Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Files: ${_uploadedFiles.length}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Size: ${_formatTotalSize(_uploadedFiles)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Files:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ..._uploadedFiles.map((file) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              _getFileIcon(file.extension),
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                file.name,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _formatFileSize(file.size),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTotalSize(List<UploadedFile> files) {
    final totalBytes = files.fold<int>(0, (sum, file) => sum + file.size);
    return _formatFileSize(totalBytes);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
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
}