import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/auth_button.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'applicant';
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return const LoadingScreen(message: 'Creating your account...');
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.subtleLight,
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Header
                  const AuthHeader(
                    title: 'Create Account',
                    subtitle: 'Join CareConnect to start your career journey.',
                  ),

                  const SizedBox(height: 32),

                  // Signup Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Full Name Field
                        CustomTextField(
                          controller: _fullNameController,
                          label: 'Full Name',
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.requiredField;
                            }
                            if (value.length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Email Field
                        CustomTextField(
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

                        // Role Selection
                        CustomDropdownField(
                          label: 'I am a',
                          value: _selectedRole,
                          items: const [
                            DropdownMenuItem(
                              value: 'applicant',
                              child: Text('Job Applicant'),
                            ),
                            DropdownMenuItem(
                              value: 'hr_admin',
                              child: Text('HR Administrator'),
                            ),
                            DropdownMenuItem(
                              value: 'hr_manager',
                              child: Text('HR Manager'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value ?? 'applicant';
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.requiredField;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Password Field
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.placeholderLight,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.requiredField;
                            }
                            if (value.length < 8) {
                              return AppStrings.passwordTooShort;
                            }
                            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)')
                                .hasMatch(value)) {
                              return 'Password must contain uppercase, lowercase, and number';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Confirm Password Field
                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.placeholderLight,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.requiredField;
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Terms Agreement
                        Row(
                          children: [
                            Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreeToTerms = value ?? false;
                                });
                              },
                              activeColor: AppColors.primary,
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodySmall,
                                  children: const [
                                    TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Error Message
                        if (authProvider.error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.error.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authProvider.error!,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Sign Up Button
                        AuthButton(
                          text: 'Create Account',
                          onPressed: _agreeToTerms ? _handleSignUp : null,
                          isLoading: authProvider.isLoading,
                        ),

                        const SizedBox(height: 24),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: const Text(
                                AppStrings.loginButton,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Try backend registration first
      bool success = await authProvider.registerWithBackend(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );

      // If backend fails, fall back to original method for demo purposes
      if (!success) {
        success = await authProvider.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          role: _selectedRole,
        );
      }

      if (success && mounted) {
        // Navigation will be handled by the router based on user role
        if (_selectedRole == 'applicant') {
          context.go('/applicant-dashboard');
        } else {
          context.go('/hr-dashboard');
        }
      } else if (mounted && authProvider.error != null) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
