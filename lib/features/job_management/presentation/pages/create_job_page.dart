import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../job_application/data/services/job_service.dart';
import '../../../job_application/domain/models/job_model.dart';

class CreateJobPage extends StatefulWidget {
  const CreateJobPage({super.key});

  @override
  State<CreateJobPage> createState() => _CreateJobPageState();
}

class _CreateJobPageState extends State<CreateJobPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryRangeController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  final _benefitsController = TextEditingController();
  
  String _selectedDepartment = 'Engineering';
  String _selectedLocation = 'Remote';
  String _selectedEmploymentType = 'Full-time';
  String _selectedExperienceLevel = 'Mid-level';
  DateTime _applicationDeadline = DateTime.now().add(const Duration(days: 30));
  
  bool _isLoading = false;

  final List<String> _departments = [
    'Engineering',
    'Marketing',
    'Sales',
    'HR',
    'Finance',
    'Operations',
    'Customer Support',
    'Design',
    'Product',
  ];

  final List<String> _locations = [
    'Remote',
    'New York, NY',
    'San Francisco, CA',
    'Austin, TX',
    'Seattle, WA',
    'Boston, MA',
    'Chicago, IL',
    'Los Angeles, CA',
  ];

  final List<String> _employmentTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Temporary',
    'Internship',
  ];

  final List<String> _experienceLevels = [
    'Entry-level',
    'Mid-level',
    'Senior-level',
    'Executive',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryRangeController.dispose();
    _requirementsController.dispose();
    _responsibilitiesController.dispose();
    _benefitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return AppHeader(
                  title: 'Create New Job',
                  subtitle: 'Post a new position for candidates',
                  user: authProvider.user,
                  showBackButton: true,
                );
              },
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Section
                      _buildSection(
                        'Basic Information',
                        [
                          _buildTextField(
                            controller: _titleController,
                            label: 'Job Title',
                            hint: 'e.g., Senior Flutter Developer',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a job title';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  label: 'Department',
                                  value: _selectedDepartment,
                                  items: _departments,
                                  onChanged: (value) => setState(() => _selectedDepartment = value!),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDropdown(
                                  label: 'Location',
                                  value: _selectedLocation,
                                  items: _locations,
                                  onChanged: (value) => setState(() => _selectedLocation = value!),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  label: 'Employment Type',
                                  value: _selectedEmploymentType,
                                  items: _employmentTypes,
                                  onChanged: (value) => setState(() => _selectedEmploymentType = value!),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDropdown(
                                  label: 'Experience Level',
                                  value: _selectedExperienceLevel,
                                  items: _experienceLevels,
                                  onChanged: (value) => setState(() => _selectedExperienceLevel = value!),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _salaryRangeController,
                            label: 'Salary Range',
                            hint: 'e.g., \$80,000 - \$120,000',
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Job Details Section
                      _buildSection(
                        'Job Details',
                        [
                          _buildTextField(
                            controller: _descriptionController,
                            label: 'Job Description',
                            hint: 'Describe the role and what the candidate will do',
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a job description';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _requirementsController,
                            label: 'Requirements',
                            hint: 'List the required skills and qualifications (one per line)',
                            maxLines: 4,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _responsibilitiesController,
                            label: 'Responsibilities',
                            hint: 'List key responsibilities (one per line)',
                            maxLines: 4,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _benefitsController,
                            label: 'Benefits',
                            hint: 'List benefits and perks (one per line)',
                            maxLines: 3,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Application Settings Section
                      _buildSection(
                        'Application Settings',
                        [
                          _buildDatePicker(
                            label: 'Application Deadline',
                            value: _applicationDeadline,
                            onChanged: (date) => setState(() => _applicationDeadline = date),
                          ),
                        ],
                      ),

                      const SizedBox(height: 48),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : () => context.pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _createJob,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Create Job'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime value,
    required void Function(DateTime) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${value.day}/${value.month}/${value.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  List<String> _parseMultilineText(String text) {
    return text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  Future<void> _createJob() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final job = JobModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        department: _selectedDepartment,
        location: _selectedLocation,
        employmentType: _selectedEmploymentType,
        experienceLevel: _selectedExperienceLevel,
        description: _descriptionController.text.trim(),
        requirements: _parseMultilineText(_requirementsController.text),
        responsibilities: _parseMultilineText(_responsibilitiesController.text),
        benefits: _parseMultilineText(_benefitsController.text),
        salaryRange: _salaryRangeController.text.trim(),
        postedDate: DateTime.now(),
        applicationDeadline: _applicationDeadline,
        status: JobStatus.active,
        postedBy: authProvider.user?.id ?? 'unknown',
        maxApplications: 100,
        currentApplications: 0,
        isRemote: _selectedLocation == 'Remote',
        skills: _parseMultilineText(_requirementsController.text),
        companyName: 'CareHR',
        contactEmail: authProvider.user?.email ?? 'hr@carehr.com',
      );

      await JobService.createJob(job);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}