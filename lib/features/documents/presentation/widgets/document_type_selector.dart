import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/models/document_model.dart';

class DocumentTypeSelector extends StatelessWidget {
  final DocumentType selectedType;
  final Function(DocumentType) onTypeChanged;

  const DocumentTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document Type',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: DocumentType.values.map((type) {
            final isSelected = type == selectedType;

            return GestureDetector(
              onTap: () => onTypeChanged(type),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : AppColors.borderLight,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIconForType(type),
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type.displayName,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getIconForType(DocumentType type) {
    switch (type) {
      case DocumentType.resume:
        return Icons.description;
      case DocumentType.coverLetter:
        return Icons.mail;
      case DocumentType.license:
        return Icons.card_membership;
      case DocumentType.certification:
        return Icons.school;
      case DocumentType.backgroundCheck:
        return Icons.verified_user;
      case DocumentType.references:
        return Icons.people;
      case DocumentType.identity:
        return Icons.badge;
      case DocumentType.other:
        return Icons.insert_drive_file;
    }
  }
}

class DocumentTypeDropdown extends StatelessWidget {
  final DocumentType selectedType;
  final Function(DocumentType) onTypeChanged;

  const DocumentTypeDropdown({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document Type',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<DocumentType>(
          value: selectedType,
          items: DocumentType.values.map((type) {
            return DropdownMenuItem<DocumentType>(
              value: type,
              child: Row(
                children: [
                  Icon(
                    _getIconForType(type),
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(type.displayName),
                ],
              ),
            );
          }).toList(),
          onChanged: (type) {
            if (type != null) {
              onTypeChanged(type);
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            border: Theme.of(context).inputDecorationTheme.border,
            enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
            contentPadding:
                Theme.of(context).inputDecorationTheme.contentPadding,
          ),
        ),
      ],
    );
  }

  IconData _getIconForType(DocumentType type) {
    switch (type) {
      case DocumentType.resume:
        return Icons.description;
      case DocumentType.coverLetter:
        return Icons.mail;
      case DocumentType.license:
        return Icons.card_membership;
      case DocumentType.certification:
        return Icons.school;
      case DocumentType.backgroundCheck:
        return Icons.verified_user;
      case DocumentType.references:
        return Icons.people;
      case DocumentType.identity:
        return Icons.badge;
      case DocumentType.other:
        return Icons.insert_drive_file;
    }
  }
}
