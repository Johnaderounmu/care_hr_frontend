import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_header.dart';

class ApplicationFormPage extends StatefulWidget {
  const ApplicationFormPage({super.key});

  @override
  State<ApplicationFormPage> createState() => _ApplicationFormPageState();
}

class _ApplicationFormPageState extends State<ApplicationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController();
  final _ethnicityController = TextEditingController();
  final _disabilityController = TextEditingController();
  final _veteranController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _ethnicityController.dispose();
    _disabilityController.dispose();
    _veteranController.dispose();
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
            AppHeader(
              title: 'Job Application',
              subtitle: 'Complete your application to join our team',
              showBackButton: true,
              onBackPressed: () {
                if (_currentStep > 0) {
                  _previousStep();
                } else {
                  context.pop();
                }
              },
            ),

            // Progress Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Progress Bar
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / _totalSteps,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                  ),

                  const SizedBox(height: 8),

                  // Step Text
                  Text(
                    'Step ${_currentStep + 1} of $_totalSteps',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildPersonalInfoStep(),
                  _buildExperienceStep(),
                  _buildEducationStep(),
                  _buildDocumentsStep(),
                ],
              ),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(AppStrings.previous),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _currentStep == _totalSteps - 1
                            ? AppStrings.submit
                            : AppStrings.next,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Title
            Text(
              AppStrings.personalInformation,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 32),

            // Form Fields
            _buildTextField(
              controller: _fullNameController,
              label: AppStrings.fullName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.requiredField;
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.requiredField;
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return AppStrings.invalidEmail;
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            _buildTextField(
              controller: _phoneController,
              label: AppStrings.phoneNumber,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.requiredField;
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Gender and Ethnicity Row
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    controller: _genderController,
                    label: AppStrings.gender,
                    items: const [
                      DropdownMenuItem(
                          value: '', child: Text(AppStrings.selectOption)),
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                      DropdownMenuItem(
                          value: 'non-binary', child: Text('Non-binary')),
                      DropdownMenuItem(
                          value: 'prefer-not-to-say',
                          child: Text('Prefer not to say')),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    controller: _ethnicityController,
                    label: AppStrings.ethnicity,
                    items: const [
                      DropdownMenuItem(
                          value: '', child: Text(AppStrings.selectOption)),
                      DropdownMenuItem(value: 'asian', child: Text('Asian')),
                      DropdownMenuItem(
                          value: 'black',
                          child: Text('Black or African American')),
                      DropdownMenuItem(
                          value: 'hispanic', child: Text('Hispanic or Latino')),
                      DropdownMenuItem(
                          value: 'native',
                          child: Text('Native American or Alaska Native')),
                      DropdownMenuItem(value: 'white', child: Text('White')),
                      DropdownMenuItem(
                          value: 'mixed', child: Text('Two or more races')),
                      DropdownMenuItem(
                          value: 'prefer-not-to-say',
                          child: Text('Prefer not to say')),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Disability and Veteran Status Row
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    controller: _disabilityController,
                    label: AppStrings.disabilityStatus,
                    items: const [
                      DropdownMenuItem(
                          value: '', child: Text(AppStrings.selectOption)),
                      DropdownMenuItem(
                          value: 'yes',
                          child: Text('Yes, I have a disability')),
                      DropdownMenuItem(
                          value: 'no',
                          child: Text('No, I don\'t have a disability')),
                      DropdownMenuItem(
                          value: 'prefer-not-to-say',
                          child: Text('Prefer not to say')),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    controller: _veteranController,
                    label: AppStrings.veteranStatus,
                    items: const [
                      DropdownMenuItem(
                          value: '', child: Text(AppStrings.selectOption)),
                      DropdownMenuItem(
                          value: 'yes', child: Text('I am a veteran')),
                      DropdownMenuItem(
                          value: 'no', child: Text('I am not a veteran')),
                      DropdownMenuItem(
                          value: 'prefer-not-to-say',
                          child: Text('Prefer not to say')),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceStep() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Work Experience',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 32),
          Text('Experience step content goes here...'),
        ],
      ),
    );
  }

  Widget _buildEducationStep() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Education',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 32),
          Text('Education step content goes here...'),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documents',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 32),
          Text('Documents step content goes here...'),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required List<DropdownMenuItem<String>> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? null : controller.text,
          items: items,
          onChanged: (value) {
            controller.text = value ?? '';
          },
          style: Theme.of(context).textTheme.bodyMedium,
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

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitApplication();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitApplication() {
    if (_formKey.currentState!.validate()) {
      // TODO: Submit application
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      context.go('/applicant-dashboard');
    }
  }
}

