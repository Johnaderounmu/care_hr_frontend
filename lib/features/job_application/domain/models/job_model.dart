import 'package:hive/hive.dart';

part 'job_model.g.dart';

@HiveType(typeId: 26)
class JobModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String department;

  @HiveField(3)
  String location;

  @HiveField(4)
  String employmentType;

  @HiveField(5)
  String experienceLevel;

  @HiveField(6)
  String description;

  @HiveField(7)
  List<String> requirements;

  @HiveField(8)
  List<String> responsibilities;

  @HiveField(9)
  List<String> benefits;

  @HiveField(10)
  String salaryRange;

  @HiveField(11)
  DateTime postedDate;

  @HiveField(12)
  DateTime applicationDeadline;

  @HiveField(13)
  JobStatus status;

  @HiveField(14)
  String postedBy;

  @HiveField(15)
  int maxApplications;

  @HiveField(16)
  int currentApplications;

  @HiveField(17)
  bool isRemote;

  @HiveField(18)
  List<String> skills;

  @HiveField(19)
  String companyName;

  @HiveField(20)
  String contactEmail;

  JobModel({
    required this.id,
    required this.title,
    required this.department,
    required this.location,
    required this.employmentType,
    required this.experienceLevel,
    required this.description,
    required this.requirements,
    required this.responsibilities,
    required this.benefits,
    required this.salaryRange,
    required this.postedDate,
    required this.applicationDeadline,
    this.status = JobStatus.active,
    required this.postedBy,
    this.maxApplications = 100,
    this.currentApplications = 0,
    this.isRemote = false,
    required this.skills,
    required this.companyName,
    required this.contactEmail,
  });

  JobModel copyWith({
    String? id,
    String? title,
    String? department,
    String? location,
    String? employmentType,
    String? experienceLevel,
    String? description,
    List<String>? requirements,
    List<String>? responsibilities,
    List<String>? benefits,
    String? salaryRange,
    DateTime? postedDate,
    DateTime? applicationDeadline,
    JobStatus? status,
    String? postedBy,
    int? maxApplications,
    int? currentApplications,
    bool? isRemote,
    List<String>? skills,
    String? companyName,
    String? contactEmail,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      department: department ?? this.department,
      location: location ?? this.location,
      employmentType: employmentType ?? this.employmentType,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      responsibilities: responsibilities ?? this.responsibilities,
      benefits: benefits ?? this.benefits,
      salaryRange: salaryRange ?? this.salaryRange,
      postedDate: postedDate ?? this.postedDate,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
      status: status ?? this.status,
      postedBy: postedBy ?? this.postedBy,
      maxApplications: maxApplications ?? this.maxApplications,
      currentApplications: currentApplications ?? this.currentApplications,
      isRemote: isRemote ?? this.isRemote,
      skills: skills ?? this.skills,
      companyName: companyName ?? this.companyName,
      contactEmail: contactEmail ?? this.contactEmail,
    );
  }

  bool get isActive => status == JobStatus.active;
  bool get isClosed => status == JobStatus.closed;
  bool get isDraft => status == JobStatus.draft;
  bool get isExpired => DateTime.now().isAfter(applicationDeadline);
  bool get canApply =>
      isActive && !isExpired && currentApplications < maxApplications;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(postedDate);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  String get deadlineText {
    final now = DateTime.now();
    final difference = applicationDeadline.difference(now);

    if (difference.isNegative) {
      return 'Deadline passed';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} left';
    } else {
      return 'Deadline today';
    }
  }
}

@HiveType(typeId: 27)
enum JobStatus {
  @HiveField(0)
  draft,

  @HiveField(1)
  active,

  @HiveField(2)
  closed,

  @HiveField(3)
  expired;

  String get displayName {
    switch (this) {
      case JobStatus.draft:
        return 'Draft';
      case JobStatus.active:
        return 'Active';
      case JobStatus.closed:
        return 'Closed';
      case JobStatus.expired:
        return 'Expired';
    }
  }
}
