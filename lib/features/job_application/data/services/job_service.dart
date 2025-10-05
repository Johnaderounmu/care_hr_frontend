import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/job_model.dart';

class JobService {
  static const String _boxName = 'jobs';
  static Box<JobModel>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<JobModel>(_boxName);
  }

  static Box<JobModel> get box {
    if (_box == null) {
      throw Exception(
          'JobService not initialized. Call JobService.init() first.');
    }
    return _box!;
  }

  // Job CRUD operations
  static Future<String> createJob(JobModel job) async {
    final jobWithId = job.copyWith(id: const Uuid().v4());
    await box.put(jobWithId.id, jobWithId);
    return jobWithId.id;
  }

  static Future<JobModel?> getJob(String id) async {
    return box.get(id);
  }

  static Future<List<JobModel>> getAllJobs() async {
    return box.values.toList();
  }

  static Future<List<JobModel>> getActiveJobs() async {
    return box.values.where((job) => job.isActive && !job.isExpired).toList();
  }

  static Future<List<JobModel>> getJobsByStatus(JobStatus status) async {
    return box.values.where((job) => job.status == status).toList();
  }

  static Future<List<JobModel>> getJobsByDepartment(String department) async {
    return box.values.where((job) => job.department == department).toList();
  }

  static Future<List<JobModel>> getJobsByLocation(String location) async {
    return box.values.where((job) => job.location == location).toList();
  }

  static Future<List<JobModel>> searchJobs(String query) async {
    final lowerQuery = query.toLowerCase();
    return box.values.where((job) {
      return job.title.toLowerCase().contains(lowerQuery) ||
          job.description.toLowerCase().contains(lowerQuery) ||
          job.department.toLowerCase().contains(lowerQuery) ||
          job.location.toLowerCase().contains(lowerQuery) ||
          job.requirements
              .any((req) => req.toLowerCase().contains(lowerQuery)) ||
          job.skills.any((skill) => skill.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  static Future<bool> updateJob(JobModel job) async {
    await box.put(job.id, job);
    return true;
  }

  static Future<bool> deleteJob(String id) async {
    await box.delete(id);
    return true;
  }

  static Future<List<JobModel>> getRecentJobs({int limit = 5}) async {
    final jobs = await getActiveJobs();
    jobs.sort((a, b) => b.postedDate.compareTo(a.postedDate));
    return jobs.take(limit).toList();
  }

  static Future<List<JobModel>> getFeaturedJobs({int limit = 3}) async {
    final jobs = await getActiveJobs();
    // Simple algorithm: jobs with more applications are considered featured
    jobs.sort((a, b) => b.currentApplications.compareTo(a.currentApplications));
    return jobs.take(limit).toList();
  }

  static Future<List<String>> getAllDepartments() async {
    final jobs = await getAllJobs();
    return jobs.map((job) => job.department).toSet().toList()..sort();
  }

  static Future<List<String>> getAllLocations() async {
    final jobs = await getAllJobs();
    return jobs.map((job) => job.location).toSet().toList()..sort();
  }

  static Future<List<String>> getAllSkills() async {
    final jobs = await getAllJobs();
    final allSkills = <String>{};
    for (final job in jobs) {
      allSkills.addAll(job.skills);
    }
    return allSkills.toList()..sort();
  }

  static Future<Map<String, int>> getJobStats() async {
    final jobs = await getAllJobs();
    return {
      'total': jobs.length,
      'active': jobs.where((job) => job.status == JobStatus.active).length,
      'draft': jobs.where((job) => job.status == JobStatus.draft).length,
      'closed': jobs.where((job) => job.status == JobStatus.closed).length,
      'expired': jobs.where((job) => job.isExpired).length,
    };
  }

  static Future<void> initializeSampleData() async {
    if (box.isNotEmpty) return;

    final sampleJobs = [
      JobModel(
        id: 'job_1',
        title: 'Senior Flutter Developer',
        department: 'Engineering',
        location: 'San Francisco, CA',
        employmentType: 'Full-time',
        experienceLevel: 'Senior',
        description:
            'We are looking for a Senior Flutter Developer to join our mobile development team. You will be responsible for building and maintaining high-quality mobile applications using Flutter framework.',
        requirements: [
          '5+ years of experience in mobile development',
          'Strong proficiency in Flutter and Dart',
          'Experience with state management solutions (Provider, Bloc, Riverpod)',
          'Knowledge of RESTful APIs and GraphQL',
          'Experience with version control (Git)',
          'Strong problem-solving skills',
        ],
        responsibilities: [
          'Develop and maintain Flutter applications',
          'Collaborate with cross-functional teams',
          'Write clean, maintainable code',
          'Participate in code reviews',
          'Debug and fix bugs',
          'Optimize application performance',
        ],
        benefits: [
          'Competitive salary',
          'Health insurance',
          '401(k) matching',
          'Flexible working hours',
          'Remote work options',
          'Professional development budget',
        ],
        salaryRange: '\$120,000 - \$160,000',
        postedDate: DateTime.now().subtract(const Duration(days: 5)),
        applicationDeadline: DateTime.now().add(const Duration(days: 25)),
        status: JobStatus.active,
        postedBy: 'hr_admin_1',
        maxApplications: 50,
        currentApplications: 12,
        isRemote: true,
        skills: ['Flutter', 'Dart', 'Mobile Development', 'REST API', 'Git'],
        companyName: 'TechCorp Inc.',
        contactEmail: 'careers@techcorp.com',
      ),
      JobModel(
        id: 'job_2',
        title: 'UX/UI Designer',
        department: 'Design',
        location: 'New York, NY',
        employmentType: 'Full-time',
        experienceLevel: 'Mid-level',
        description:
            'We are seeking a talented UX/UI Designer to create intuitive and engaging user experiences for our digital products. You will work closely with product managers and developers to bring designs to life.',
        requirements: [
          '3+ years of UX/UI design experience',
          'Proficiency in Figma, Sketch, or Adobe XD',
          'Strong portfolio showcasing UX/UI work',
          'Understanding of user research methods',
          'Knowledge of design systems',
          'Experience with prototyping tools',
        ],
        responsibilities: [
          'Create user-centered designs',
          'Conduct user research and testing',
          'Develop wireframes and prototypes',
          'Collaborate with development teams',
          'Maintain design systems',
          'Present design solutions to stakeholders',
        ],
        benefits: [
          'Competitive salary',
          'Health insurance',
          'Dental and vision coverage',
          'Flexible PTO',
          'Design conference attendance',
          'Latest design tools and software',
        ],
        salaryRange: '\$80,000 - \$110,000',
        postedDate: DateTime.now().subtract(const Duration(days: 3)),
        applicationDeadline: DateTime.now().add(const Duration(days: 27)),
        status: JobStatus.active,
        postedBy: 'hr_admin_1',
        maxApplications: 30,
        currentApplications: 8,
        isRemote: false,
        skills: [
          'UX Design',
          'UI Design',
          'Figma',
          'User Research',
          'Prototyping'
        ],
        companyName: 'DesignStudio',
        contactEmail: 'jobs@designstudio.com',
      ),
      JobModel(
        id: 'job_3',
        title: 'Product Manager',
        department: 'Product',
        location: 'Austin, TX',
        employmentType: 'Full-time',
        experienceLevel: 'Senior',
        description:
            'We are looking for an experienced Product Manager to lead product strategy and execution. You will work with cross-functional teams to deliver products that meet customer needs and business objectives.',
        requirements: [
          '5+ years of product management experience',
          'Experience with agile methodologies',
          'Strong analytical and problem-solving skills',
          'Excellent communication and leadership skills',
          'Experience with product analytics tools',
          'Technical background preferred',
        ],
        responsibilities: [
          'Define product strategy and roadmap',
          'Gather and prioritize product requirements',
          'Work with engineering teams on product development',
          'Analyze product performance and user feedback',
          'Coordinate product launches',
          'Manage stakeholder relationships',
        ],
        benefits: [
          'Competitive salary and equity',
          'Comprehensive health benefits',
          'Unlimited PTO',
          'Learning and development budget',
          'Stock options',
          'Flexible work arrangements',
        ],
        salaryRange: '\$130,000 - \$180,000',
        postedDate: DateTime.now().subtract(const Duration(days: 7)),
        applicationDeadline: DateTime.now().add(const Duration(days: 23)),
        status: JobStatus.active,
        postedBy: 'hr_admin_2',
        maxApplications: 40,
        currentApplications: 15,
        isRemote: true,
        skills: [
          'Product Management',
          'Agile',
          'Analytics',
          'Strategy',
          'Leadership'
        ],
        companyName: 'InnovateTech',
        contactEmail: 'careers@innovatetech.com',
      ),
      JobModel(
        id: 'job_4',
        title: 'Marketing Specialist',
        department: 'Marketing',
        location: 'Chicago, IL',
        employmentType: 'Full-time',
        experienceLevel: 'Mid-level',
        description:
            'Join our marketing team as a Marketing Specialist. You will be responsible for developing and executing marketing campaigns to drive brand awareness and customer acquisition.',
        requirements: [
          '3+ years of marketing experience',
          'Experience with digital marketing channels',
          'Proficiency in marketing analytics tools',
          'Strong written and verbal communication skills',
          'Experience with social media marketing',
          'Knowledge of SEO and SEM',
        ],
        responsibilities: [
          'Develop marketing campaigns',
          'Manage social media presence',
          'Analyze marketing performance',
          'Create marketing content',
          'Coordinate with external agencies',
          'Support event planning and execution',
        ],
        benefits: [
          'Competitive salary',
          'Health and wellness benefits',
          'Professional development opportunities',
          'Flexible work schedule',
          'Team building events',
          'Marketing tools and software',
        ],
        salaryRange: '\$60,000 - \$85,000',
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
        applicationDeadline: DateTime.now().add(const Duration(days: 28)),
        status: JobStatus.active,
        postedBy: 'hr_admin_1',
        maxApplications: 25,
        currentApplications: 5,
        isRemote: false,
        skills: [
          'Digital Marketing',
          'Social Media',
          'Analytics',
          'Content Creation',
          'SEO'
        ],
        companyName: 'GrowthCorp',
        contactEmail: 'hr@growthcorp.com',
      ),
      JobModel(
        id: 'job_5',
        title: 'Data Scientist',
        department: 'Data & Analytics',
        location: 'Seattle, WA',
        employmentType: 'Full-time',
        experienceLevel: 'Senior',
        description:
            'We are seeking a Data Scientist to join our analytics team. You will work on complex data problems, build machine learning models, and provide insights to drive business decisions.',
        requirements: [
          '4+ years of experience in data science',
          'Strong programming skills in Python or R',
          'Experience with machine learning frameworks',
          'Knowledge of statistical analysis',
          'Experience with SQL and databases',
          'Strong problem-solving and analytical skills',
        ],
        responsibilities: [
          'Develop and deploy machine learning models',
          'Analyze large datasets to extract insights',
          'Collaborate with business stakeholders',
          'Present findings to technical and non-technical audiences',
          'Maintain and improve existing models',
          'Stay current with data science trends',
        ],
        benefits: [
          'Competitive salary and bonuses',
          'Comprehensive health coverage',
          '401(k) with company matching',
          'Flexible working hours',
          'Conference and training budget',
          'Top-tier equipment and software',
        ],
        salaryRange: '\$140,000 - \$190,000',
        postedDate: DateTime.now().subtract(const Duration(days: 1)),
        applicationDeadline: DateTime.now().add(const Duration(days: 29)),
        status: JobStatus.active,
        postedBy: 'hr_admin_2',
        maxApplications: 35,
        currentApplications: 9,
        isRemote: true,
        skills: [
          'Python',
          'Machine Learning',
          'Statistics',
          'SQL',
          'Data Analysis'
        ],
        companyName: 'DataFlow Solutions',
        contactEmail: 'careers@dataflow.com',
      ),
    ];

    for (final job in sampleJobs) {
      await box.put(job.id, job);
    }
  }

  static Future<void> close() async {
    await _box?.close();
  }
}
