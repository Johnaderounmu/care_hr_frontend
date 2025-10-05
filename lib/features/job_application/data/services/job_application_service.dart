import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/job_application_model.dart';

class JobApplicationService {
  static const String _boxName = 'job_applications';
  static Box<JobApplicationModel>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<JobApplicationModel>(_boxName);
  }

  static Box<JobApplicationModel> get box {
    if (_box == null) {
      throw Exception(
          'JobApplicationService not initialized. Call JobApplicationService.init() first.');
    }
    return _box!;
  }

  // Job Application CRUD operations
  static Future<String> createApplication(
      JobApplicationModel application) async {
    final applicationWithId = application.copyWith(id: const Uuid().v4());
    await box.put(applicationWithId.id, applicationWithId);
    return applicationWithId.id;
  }

  static Future<JobApplicationModel?> getApplication(String id) async {
    return box.get(id);
  }

  static Future<List<JobApplicationModel>> getAllApplications() async {
    return box.values.toList();
  }

  static Future<List<JobApplicationModel>> getApplicationsByJob(
      String jobId) async {
    return box.values.where((app) => app.jobId == jobId).toList();
  }

  static Future<List<JobApplicationModel>> getApplicationsByApplicant(
      String applicantId) async {
    return box.values.where((app) => app.applicantId == applicantId).toList();
  }

  static Future<List<JobApplicationModel>> getApplicationsByStatus(
      ApplicationStatus status) async {
    return box.values.where((app) => app.status == status).toList();
  }

  static Future<List<JobApplicationModel>> getRecentApplications(
      {int limit = 10}) async {
    final applications = await getAllApplications();
    applications.sort((a, b) => b.appliedDate.compareTo(a.appliedDate));
    return applications.take(limit).toList();
  }

  static Future<bool> updateApplication(JobApplicationModel application) async {
    final updatedApplication =
        application.copyWith(lastUpdated: DateTime.now());
    await box.put(updatedApplication.id, updatedApplication);
    return true;
  }

  static Future<bool> deleteApplication(String id) async {
    await box.delete(id);
    return true;
  }

  // Application status management
  static Future<bool> updateApplicationStatus(
    String applicationId,
    ApplicationStatus newStatus, {
    String? notes,
    String? reviewedBy,
    String? rejectionReason,
  }) async {
    final application = await getApplication(applicationId);
    if (application == null) return false;

    final updatedApplication = application.copyWith(
      status: newStatus,
      notes: notes ?? application.notes,
      reviewedBy: reviewedBy ?? application.reviewedBy,
      reviewedDate: DateTime.now(),
      rejectionReason: rejectionReason,
      rejectionDate:
          newStatus == ApplicationStatus.rejected ? DateTime.now() : null,
    );

    return await updateApplication(updatedApplication);
  }

  static Future<bool> shortlistApplication(
      String applicationId, String reviewedBy,
      {String? notes}) async {
    return await updateApplicationStatus(
      applicationId,
      ApplicationStatus.shortlisted,
      notes: notes,
      reviewedBy: reviewedBy,
    );
  }

  static Future<bool> rejectApplication(
    String applicationId,
    String rejectionReason,
    String reviewedBy, {
    String? notes,
  }) async {
    return await updateApplicationStatus(
      applicationId,
      ApplicationStatus.rejected,
      rejectionReason: rejectionReason,
      notes: notes,
      reviewedBy: reviewedBy,
    );
  }

  static Future<bool> hireApplication(String applicationId, String reviewedBy,
      {String? notes}) async {
    return await updateApplicationStatus(
      applicationId,
      ApplicationStatus.hired,
      notes: notes,
      reviewedBy: reviewedBy,
    );
  }

  // Interview management
  static Future<String> scheduleInterview(
    String applicationId,
    InterviewModel interview,
  ) async {
    final application = await getApplication(applicationId);
    if (application == null) throw Exception('Application not found');

    final interviewWithId = interview.copyWith(id: const Uuid().v4());
    final updatedApplication = application.copyWith(
      status: ApplicationStatus.interviewScheduled,
      interviews: [...application.interviews, interviewWithId],
    );

    await updateApplication(updatedApplication);
    return interviewWithId.id;
  }

  static Future<bool> updateInterview(
      String applicationId, InterviewModel updatedInterview) async {
    final application = await getApplication(applicationId);
    if (application == null) return false;

    final interviews = application.interviews.map((interview) {
      return interview.id == updatedInterview.id ? updatedInterview : interview;
    }).toList();

    final updatedApplication = application.copyWith(interviews: interviews);
    return await updateApplication(updatedApplication);
  }

  static Future<bool> completeInterview(
    String applicationId,
    String interviewId,
    String feedback,
    int rating,
  ) async {
    final application = await getApplication(applicationId);
    if (application == null) return false;

    final interviews = application.interviews.map((interview) {
      if (interview.id == interviewId) {
        return interview.copyWith(
          status: InterviewStatus.completed,
          feedback: feedback,
          rating: rating,
          completedDate: DateTime.now(),
        );
      }
      return interview;
    }).toList();

    final updatedApplication = application.copyWith(
      interviews: interviews,
      status: ApplicationStatus.interviewCompleted,
    );

    return await updateApplication(updatedApplication);
  }

  // Scoring system
  static Future<bool> scoreApplication(
    String applicationId,
    ApplicationScore score,
  ) async {
    final application = await getApplication(applicationId);
    if (application == null) return false;

    final updatedApplication = application.copyWith(score: score);
    return await updateApplication(updatedApplication);
  }

  // Search and filtering
  static Future<List<JobApplicationModel>> searchApplications(
      String query) async {
    final lowerQuery = query.toLowerCase();
    return box.values.where((app) {
      return app.applicantName.toLowerCase().contains(lowerQuery) ||
          app.applicantEmail.toLowerCase().contains(lowerQuery) ||
          app.notes?.toLowerCase().contains(lowerQuery) == true ||
          app.coverLetter?.toLowerCase().contains(lowerQuery) == true;
    }).toList();
  }

  static Future<List<JobApplicationModel>> filterApplications({
    ApplicationStatus? status,
    String? jobId,
    String? applicantId,
    DateTime? fromDate,
    DateTime? toDate,
    bool? isArchived,
  }) async {
    return box.values.where((app) {
      if (status != null && app.status != status) return false;
      if (jobId != null && app.jobId != jobId) return false;
      if (applicantId != null && app.applicantId != applicantId) return false;
      if (fromDate != null && app.appliedDate.isBefore(fromDate)) return false;
      if (toDate != null && app.appliedDate.isAfter(toDate)) return false;
      if (isArchived != null && app.isArchived != isArchived) return false;
      return true;
    }).toList();
  }

  // Statistics
  static Future<Map<String, int>> getApplicationStats() async {
    final applications = await getAllApplications();
    return {
      'total': applications.length,
      'submitted': applications
          .where((app) => app.status == ApplicationStatus.submitted)
          .length,
      'underReview': applications
          .where((app) => app.status == ApplicationStatus.underReview)
          .length,
      'shortlisted': applications
          .where((app) => app.status == ApplicationStatus.shortlisted)
          .length,
      'interviewScheduled': applications
          .where((app) => app.status == ApplicationStatus.interviewScheduled)
          .length,
      'interviewCompleted': applications
          .where((app) => app.status == ApplicationStatus.interviewCompleted)
          .length,
      'rejected': applications
          .where((app) => app.status == ApplicationStatus.rejected)
          .length,
      'hired': applications
          .where((app) => app.status == ApplicationStatus.hired)
          .length,
      'withdrawn': applications
          .where((app) => app.status == ApplicationStatus.withdrawn)
          .length,
    };
  }

  static Future<Map<String, int>> getApplicationStatsByJob(String jobId) async {
    final applications = await getApplicationsByJob(jobId);
    return {
      'total': applications.length,
      'submitted': applications
          .where((app) => app.status == ApplicationStatus.submitted)
          .length,
      'underReview': applications
          .where((app) => app.status == ApplicationStatus.underReview)
          .length,
      'shortlisted': applications
          .where((app) => app.status == ApplicationStatus.shortlisted)
          .length,
      'interviewScheduled': applications
          .where((app) => app.status == ApplicationStatus.interviewScheduled)
          .length,
      'interviewCompleted': applications
          .where((app) => app.status == ApplicationStatus.interviewCompleted)
          .length,
      'rejected': applications
          .where((app) => app.status == ApplicationStatus.rejected)
          .length,
      'hired': applications
          .where((app) => app.status == ApplicationStatus.hired)
          .length,
      'withdrawn': applications
          .where((app) => app.status == ApplicationStatus.withdrawn)
          .length,
    };
  }

  static Future<void> initializeSampleData() async {
    if (box.isNotEmpty) return;

    final sampleApplications = [
      JobApplicationModel(
        id: 'app_1',
        jobId: 'job_1',
        applicantId: 'applicant_1',
        applicantName: 'John Smith',
        applicantEmail: 'john.smith@email.com',
        status: ApplicationStatus.underReview,
        appliedDate: DateTime.now().subtract(const Duration(days: 3)),
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        coverLetter:
            'I am excited to apply for the Senior Flutter Developer position. With over 6 years of experience in mobile development and a strong passion for creating innovative solutions, I believe I would be a great fit for your team.',
        documentIds: ['doc_1', 'doc_2'],
        source: 'Company Website',
        notes: 'Strong technical background, excellent communication skills.',
      ),
      JobApplicationModel(
        id: 'app_2',
        jobId: 'job_1',
        applicantId: 'applicant_2',
        applicantName: 'Sarah Johnson',
        applicantEmail: 'sarah.johnson@email.com',
        status: ApplicationStatus.shortlisted,
        appliedDate: DateTime.now().subtract(const Duration(days: 5)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        coverLetter:
            'I am writing to express my interest in the Senior Flutter Developer role. My extensive experience with Flutter and Dart, combined with my passion for mobile development, makes me an ideal candidate.',
        documentIds: ['doc_3', 'doc_4'],
        source: 'LinkedIn',
        notes: 'Top candidate, impressive portfolio, ready for interview.',
        reviewedBy: 'hr_admin_1',
        reviewedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      JobApplicationModel(
        id: 'app_3',
        jobId: 'job_2',
        applicantId: 'applicant_3',
        applicantName: 'Michael Chen',
        applicantEmail: 'michael.chen@email.com',
        status: ApplicationStatus.interviewScheduled,
        appliedDate: DateTime.now().subtract(const Duration(days: 2)),
        lastUpdated: DateTime.now().subtract(const Duration(hours: 4)),
        coverLetter:
            'I am thrilled to apply for the UX/UI Designer position. My creative approach to design and user-centered methodology align perfectly with your company values.',
        documentIds: ['doc_5'],
        source: 'Indeed',
        interviews: [
          InterviewModel(
            id: 'interview_1',
            applicationId: 'app_3',
            applicantId: 'applicant_3',
            applicantName: 'Michael Chen',
            type: InterviewType.video,
            status: InterviewStatus.scheduled,
            scheduledDate: DateTime.now().add(const Duration(days: 3)),
            duration: 60,
            location: 'Video Call',
            interviewerIds: ['hr_admin_1'],
            interviewerNames: ['Jane Smith'],
            meetingLink: 'https://meet.google.com/abc-defg-hij',
            isRemote: true,
          ),
        ],
        notes: 'Scheduled for video interview next week.',
        reviewedBy: 'hr_admin_1',
        reviewedDate: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      JobApplicationModel(
        id: 'app_4',
        jobId: 'job_1',
        applicantId: 'applicant_4',
        applicantName: 'Emily Davis',
        applicantEmail: 'emily.davis@email.com',
        status: ApplicationStatus.rejected,
        appliedDate: DateTime.now().subtract(const Duration(days: 7)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
        coverLetter:
            'I am interested in the Senior Flutter Developer position. I have experience with mobile development and am eager to learn Flutter.',
        documentIds: ['doc_6'],
        source: 'Company Website',
        rejectionReason: 'Insufficient Flutter experience',
        rejectionDate: DateTime.now().subtract(const Duration(days: 2)),
        notes: 'Candidate lacks required Flutter experience.',
        reviewedBy: 'hr_admin_1',
        reviewedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      JobApplicationModel(
        id: 'app_5',
        jobId: 'job_3',
        applicantId: 'applicant_5',
        applicantName: 'David Wilson',
        applicantEmail: 'david.wilson@email.com',
        status: ApplicationStatus.hired,
        appliedDate: DateTime.now().subtract(const Duration(days: 10)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        coverLetter:
            'I am excited to apply for the Product Manager position. My background in product strategy and cross-functional leadership makes me a strong candidate.',
        documentIds: ['doc_7', 'doc_8'],
        source: 'Referral',
        notes: 'Excellent candidate, hired after successful interview process.',
        reviewedBy: 'hr_admin_2',
        reviewedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    for (final application in sampleApplications) {
      await box.put(application.id, application);
    }
  }

  static Future<void> close() async {
    await _box?.close();
  }
}
