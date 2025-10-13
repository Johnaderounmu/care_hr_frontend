import 'package:hive/hive.dart';

part 'job_model.g.dart';

@HiveType(typeId: 10)
class JobModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String? requirements;

  @HiveField(4)
  final String department;

  @HiveField(5)
  final String location;

  @HiveField(6)
  final String type; // full_time, part_time, contract, internship

  @HiveField(7)
  final String status; // draft, published, active, closed, archived, cancelled

  @HiveField(8)
  final String? salaryRange;

  @HiveField(9)
  final String? experienceLevel; // entry, junior, mid, senior, lead, executive

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime? updatedAt;

  @HiveField(12)
  final String? createdById;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    this.requirements,
    required this.department,
    required this.location,
    required this.type,
    required this.status,
    this.salaryRange,
    this.experienceLevel,
    required this.createdAt,
    this.updatedAt,
    this.createdById,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    // Handle requirements field - can be array or string
    String? requirementsText;
    if (json['requirements'] != null) {
      if (json['requirements'] is List) {
        // Convert array to comma-separated string
        final reqList = List<String>.from(json['requirements']);
        requirementsText = reqList.join(', ');
      } else {
        requirementsText = json['requirements'].toString();
      }
    }
    
    // Handle salary field - backend uses 'salary', model uses 'salaryRange'
    String? salaryText = json['salaryRange'] ?? json['salary'];
    
    return JobModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      requirements: requirementsText,
      department: json['department'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      salaryRange: salaryText,
      experienceLevel: json['experienceLevel'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      createdById: json['createdById'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'requirements': requirements,
      'department': department,
      'location': location,
      'type': type,
      'status': status,
      'salaryRange': salaryRange,
      'experienceLevel': experienceLevel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdById': createdById,
    };
  }

  @override
  String toString() {
    return 'JobModel(id: $id, title: $title, department: $department, status: $status)';
  }
}