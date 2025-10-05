import 'package:hive/hive.dart';

// removed unused import

part 'job_application_model.g.dart';

@HiveType(typeId: 30)
class JobApplicationModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String jobId;

  @HiveField(2)
  String applicantId;

  @HiveField(3)
  String applicantName;

  @HiveField(4)
  String applicantEmail;

  @HiveField(5)
  ApplicationStatus status;

  @HiveField(6)
  DateTime appliedDate;

  @HiveField(7)
  DateTime? lastUpdated;

  @HiveField(8)
  String? coverLetter;

  @HiveField(9)
  List<String> documentIds;

  @HiveField(10)
  Map<String, dynamic>? applicationData;

  @HiveField(11)
  String? notes;

  @HiveField(12)
  String? reviewedBy;

  @HiveField(13)
  DateTime? reviewedDate;

  @HiveField(14)
  ApplicationScore? score;

  @HiveField(15)
  List<InterviewModel> interviews;

  @HiveField(16)
  String? rejectionReason;

  @HiveField(17)
  DateTime? rejectionDate;

  @HiveField(18)
  bool isArchived;

  @HiveField(19)
  String? source;

  @HiveField(20)
  String? referralSource;

  JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.applicantId,
    required this.applicantName,
    required this.applicantEmail,
    this.status = ApplicationStatus.submitted,
    required this.appliedDate,
    this.lastUpdated,
    this.coverLetter,
    this.documentIds = const [],
    this.applicationData,
    this.notes,
    this.reviewedBy,
    this.reviewedDate,
    this.score,
    this.interviews = const [],
    this.rejectionReason,
    this.rejectionDate,
    this.isArchived = false,
    this.source,
    this.referralSource,
  });

  JobApplicationModel copyWith({
    String? id,
    String? jobId,
    String? applicantId,
    String? applicantName,
    String? applicantEmail,
    ApplicationStatus? status,
    DateTime? appliedDate,
    DateTime? lastUpdated,
    String? coverLetter,
    List<String>? documentIds,
    Map<String, dynamic>? applicationData,
    String? notes,
    String? reviewedBy,
    DateTime? reviewedDate,
    ApplicationScore? score,
    List<InterviewModel>? interviews,
    String? rejectionReason,
    DateTime? rejectionDate,
    bool? isArchived,
    String? source,
    String? referralSource,
  }) {
    return JobApplicationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      applicantId: applicantId ?? this.applicantId,
      applicantName: applicantName ?? this.applicantName,
      applicantEmail: applicantEmail ?? this.applicantEmail,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      coverLetter: coverLetter ?? this.coverLetter,
      documentIds: documentIds ?? this.documentIds,
      applicationData: applicationData ?? this.applicationData,
      notes: notes ?? this.notes,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedDate: reviewedDate ?? this.reviewedDate,
      score: score ?? this.score,
      interviews: interviews ?? this.interviews,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      rejectionDate: rejectionDate ?? this.rejectionDate,
      isArchived: isArchived ?? this.isArchived,
      source: source ?? this.source,
      referralSource: referralSource ?? this.referralSource,
    );
  }

  bool get isNew => status == ApplicationStatus.submitted;
  bool get isUnderReview => status == ApplicationStatus.underReview;
  bool get isShortlisted => status == ApplicationStatus.shortlisted;
  bool get isRejected => status == ApplicationStatus.rejected;
  bool get isHired => status == ApplicationStatus.hired;
  bool get isWithdrawn => status == ApplicationStatus.withdrawn;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(appliedDate);

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

  String get statusText {
    switch (status) {
      case ApplicationStatus.submitted:
        return 'Application Submitted';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.interviewScheduled:
        return 'Interview Scheduled';
      case ApplicationStatus.interviewCompleted:
        return 'Interview Completed';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.hired:
        return 'Hired';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  InterviewModel? get nextInterview {
    final now = DateTime.now();
    final upcomingInterviews = interviews
        .where((interview) => interview.scheduledDate.isAfter(now))
        .toList();

    if (upcomingInterviews.isEmpty) return null;

    upcomingInterviews
        .sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return upcomingInterviews.first;
  }

  InterviewModel? get lastInterview {
    if (interviews.isEmpty) return null;

    interviews.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
    return interviews.first;
  }
}

@HiveType(typeId: 31)
enum ApplicationStatus {
  @HiveField(0)
  submitted,

  @HiveField(1)
  underReview,

  @HiveField(2)
  shortlisted,

  @HiveField(3)
  interviewScheduled,

  @HiveField(4)
  interviewCompleted,

  @HiveField(5)
  rejected,

  @HiveField(6)
  hired,

  @HiveField(7)
  withdrawn;

  String get displayName {
    switch (this) {
      case ApplicationStatus.submitted:
        return 'Submitted';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.interviewScheduled:
        return 'Interview Scheduled';
      case ApplicationStatus.interviewCompleted:
        return 'Interview Completed';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.hired:
        return 'Hired';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }
}

@HiveType(typeId: 32)
class ApplicationScore extends HiveObject {
  @HiveField(0)
  int overallScore;

  @HiveField(1)
  int experienceScore;

  @HiveField(2)
  int skillsScore;

  @HiveField(3)
  int educationScore;

  @HiveField(4)
  int interviewScore;

  @HiveField(5)
  String? comments;

  @HiveField(6)
  String scoredBy;

  @HiveField(7)
  DateTime scoredDate;

  ApplicationScore({
    required this.overallScore,
    required this.experienceScore,
    required this.skillsScore,
    required this.educationScore,
    required this.interviewScore,
    this.comments,
    required this.scoredBy,
    required this.scoredDate,
  });

  double get overallPercentage => (overallScore / 100) * 100;
  double get experiencePercentage => (experienceScore / 100) * 100;
  double get skillsPercentage => (skillsScore / 100) * 100;
  double get educationPercentage => (educationScore / 100) * 100;
  double get interviewPercentage => (interviewScore / 100) * 100;
}

@HiveType(typeId: 33)
class InterviewModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String applicationId;

  @HiveField(2)
  String applicantId;

  @HiveField(3)
  String applicantName;

  @HiveField(4)
  InterviewType type;

  @HiveField(5)
  InterviewStatus status;

  @HiveField(6)
  DateTime scheduledDate;

  @HiveField(7)
  int duration; // in minutes

  @HiveField(8)
  String location;

  @HiveField(9)
  List<String> interviewerIds;

  @HiveField(10)
  List<String> interviewerNames;

  @HiveField(11)
  String? meetingLink;

  @HiveField(12)
  String? notes;

  @HiveField(13)
  String? feedback;

  @HiveField(14)
  int? rating;

  @HiveField(15)
  DateTime? completedDate;

  @HiveField(16)
  DateTime? rescheduledDate;

  @HiveField(17)
  String? rescheduleReason;

  @HiveField(18)
  bool isRemote;

  @HiveField(19)
  Map<String, dynamic>? interviewQuestions;

  InterviewModel({
    required this.id,
    required this.applicationId,
    required this.applicantId,
    required this.applicantName,
    required this.type,
    this.status = InterviewStatus.scheduled,
    required this.scheduledDate,
    this.duration = 60,
    required this.location,
    required this.interviewerIds,
    required this.interviewerNames,
    this.meetingLink,
    this.notes,
    this.feedback,
    this.rating,
    this.completedDate,
    this.rescheduledDate,
    this.rescheduleReason,
    this.isRemote = false,
    this.interviewQuestions,
  });

  InterviewModel copyWith({
    String? id,
    String? applicationId,
    String? applicantId,
    String? applicantName,
    InterviewType? type,
    InterviewStatus? status,
    DateTime? scheduledDate,
    int? duration,
    String? location,
    List<String>? interviewerIds,
    List<String>? interviewerNames,
    String? meetingLink,
    String? notes,
    String? feedback,
    int? rating,
    DateTime? completedDate,
    DateTime? rescheduledDate,
    String? rescheduleReason,
    bool? isRemote,
    Map<String, dynamic>? interviewQuestions,
  }) {
    return InterviewModel(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      applicantId: applicantId ?? this.applicantId,
      applicantName: applicantName ?? this.applicantName,
      type: type ?? this.type,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      duration: duration ?? this.duration,
      location: location ?? this.location,
      interviewerIds: interviewerIds ?? this.interviewerIds,
      interviewerNames: interviewerNames ?? this.interviewerNames,
      meetingLink: meetingLink ?? this.meetingLink,
      notes: notes ?? this.notes,
      feedback: feedback ?? this.feedback,
      rating: rating ?? this.rating,
      completedDate: completedDate ?? this.completedDate,
      rescheduledDate: rescheduledDate ?? this.rescheduledDate,
      rescheduleReason: rescheduleReason ?? this.rescheduleReason,
      isRemote: isRemote ?? this.isRemote,
      interviewQuestions: interviewQuestions ?? this.interviewQuestions,
    );
  }

  bool get isUpcoming =>
      scheduledDate.isAfter(DateTime.now()) &&
      status == InterviewStatus.scheduled;
  bool get isCompleted => status == InterviewStatus.completed;
  bool get isCancelled => status == InterviewStatus.cancelled;
  bool get isRescheduled => status == InterviewStatus.rescheduled;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(scheduledDate);

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

  String get scheduledTimeText {
    return '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year} at ${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}';
  }
}

@HiveType(typeId: 34)
enum InterviewType {
  @HiveField(0)
  phone,

  @HiveField(1)
  video,

  @HiveField(2)
  inPerson,

  @HiveField(3)
  technical,

  @HiveField(4)
  panel;

  String get displayName {
    switch (this) {
      case InterviewType.phone:
        return 'Phone Interview';
      case InterviewType.video:
        return 'Video Interview';
      case InterviewType.inPerson:
        return 'In-Person Interview';
      case InterviewType.technical:
        return 'Technical Interview';
      case InterviewType.panel:
        return 'Panel Interview';
    }
  }
}

@HiveType(typeId: 35)
enum InterviewStatus {
  @HiveField(0)
  scheduled,

  @HiveField(1)
  completed,

  @HiveField(2)
  cancelled,

  @HiveField(3)
  rescheduled,

  @HiveField(4)
  noShow;

  String get displayName {
    switch (this) {
      case InterviewStatus.scheduled:
        return 'Scheduled';
      case InterviewStatus.completed:
        return 'Completed';
      case InterviewStatus.cancelled:
        return 'Cancelled';
      case InterviewStatus.rescheduled:
        return 'Rescheduled';
      case InterviewStatus.noShow:
        return 'No Show';
    }
  }
}
