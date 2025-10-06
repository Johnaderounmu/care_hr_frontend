import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/custom_file_picker_service.dart';
import '../../../../core/utils/custom_platform_file.dart';

class FileUploadArea extends StatefulWidget {
  final List<dynamic> selectedFiles;
  final Function(List<CustomPlatformFile>) onFilesSelected;
  final bool isLoading;

  const FileUploadArea({
    super.key,
    required this.selectedFiles,
    required this.onFilesSelected,
    this.isLoading = false,
  });

  @override
  State<FileUploadArea> createState() => _FileUploadAreaState();
}

class _FileUploadAreaState extends State<FileUploadArea> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickFiles,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isDragOver
              ? AppColors.primary.withOpacity(0.05)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isDragOver
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.4),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: DragTarget<CustomPlatformFile>(
          onWillAcceptWithDetails: (details) => true,
          onAcceptWithDetails: (details) {
            final file = details.data;
            setState(() {
              _isDragOver = false;
            });
            widget.onFilesSelected([file]);
          },
          onLeave: (data) {
            setState(() {
              _isDragOver = false;
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Upload Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Upload Text
                  Text(
                    'Tap to select files',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Choose from camera or gallery',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                  ),

                  const SizedBox(height: 16),

                  // Browse Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Select Files',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // File Format Info
                  Text(
                    'Supported formats: Images (JPG, PNG) and documents',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Max file size: 10MB',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickFiles() async {
    try {
      final result = await CustomFilePickerService.pickFiles(
        context: context,
        allowMultiple: true,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.isNotEmpty) {
        widget.onFilesSelected(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking files: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class FileUploadProgress extends StatelessWidget {
  final double progress;
  final String fileName;

  const FileUploadProgress({
    super.key,
    required this.progress,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.upload_file,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fileName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}
