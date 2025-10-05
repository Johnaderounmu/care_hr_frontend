import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/auth_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              return const LoadingScreen(message: 'Signing you in...');
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Header
                  const AuthHeader(
                    title: AppStrings.loginTitle,
                    subtitle: AppStrings.loginSubtitle,
                  ),

                  const SizedBox(height: 48),

                  // Login Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        CustomTextField(
                          controller: _emailController,
                          label: AppStrings.emailHint,
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

                        const SizedBox(height: 24),

                        // Password Field
                        CustomTextField(
                          controller: _passwordController,
                          label: AppStrings.passwordHint,
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
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Remember Me & Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                ),
                                Text(
                                  'Remember me',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                context.push('/forgot-password');
                              },
                              child: const Text(
                                AppStrings.forgotPassword,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

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

                        // Login Button
                        AuthButton(
                          text: AppStrings.loginButton,
                          onPressed: _handleLogin,
                        ),

                        const SizedBox(height: 24),

                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.noAccount,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 4),
                            TextButton(
                              onPressed: () {
                                context.push('/signup');
                              },
                              child: const Text(
                                AppStrings.signUp,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Dev auto-login (debug only)
                        if (kDebugMode)
                          Column(
                            children: [
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () async {
                                  final router = GoRouter.of(context);
                                  final authProvider =
                                      Provider.of<AuthProvider>(context,
                                          listen: false);

                                  final ok = await authProvider.devSignInAs(
                                    email: 'admin@carehr.com',
                                    fullName: 'Dev Admin',
                                    role: 'admin',
                                  );

                                  if (ok) {
                                    if (!mounted) return;
                                    router.go('/hr-dashboard');
                                  }
                                },
                                child: const Text('Auto-login (dev)'),
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

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Try backend authentication first
      bool success = await authProvider.loginWithBackend(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // If backend fails, fall back to original method for demo purposes
      if (!success) {
        success = await authProvider.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (success && mounted) {
        // Navigation will be handled by the router
        context.go('/hr-dashboard'); // Default redirect, router will handle proper routing
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
