import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/onboarding/presentation/pages/onboarding_screen.dart';

class OnboardingService {
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyUserType = 'user_type';

  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  static Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, true);
  }

  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, false);
  }

  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserType);
  }

  static Future<void> setUserType(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserType, userType);
  }

  static Future<bool> shouldShowOnboarding(String userType) async {
    final hasCompleted = await hasCompletedOnboarding();
    final storedUserType = await getUserType();
    
    // Show onboarding if:
    // 1. Never completed onboarding, OR
    // 2. User type has changed (switching from applicant to HR or vice versa)
    return !hasCompleted || storedUserType != userType;
  }
}

// Tutorial step data for guided tours
class TutorialData {
  static List<TourStep> getDashboardTour() {
    return [
      TourStep(
        title: 'Navigation Menu',
        description: 'Access all app features from this menu. Tap to navigate between different sections.',
        targetPosition: const Offset(20, 100),
        targetSize: const Size(60, 60),
        icon: Icons.menu,
      ),
      TourStep(
        title: 'Search & Filter',
        description: 'Quickly find what you\'re looking for using the search bar and filters.',
        targetPosition: const Offset(80, 100),
        targetSize: const Size(200, 40),
        icon: Icons.search,
      ),
      TourStep(
        title: 'Notifications',
        description: 'Stay updated with real-time notifications about your applications and messages.',
        targetPosition: const Offset(320, 100),
        targetSize: const Size(40, 40),
        icon: Icons.notifications,
      ),
      TourStep(
        title: 'Quick Actions',
        description: 'Access frequently used actions directly from the dashboard for faster workflow.',
        targetPosition: const Offset(50, 200),
        targetSize: const Size(300, 100),
        icon: Icons.flash_on,
      ),
    ];
  }

  static List<TourStep> getApplicationTour() {
    return [
      TourStep(
        title: 'Application Form',
        description: 'Fill out your application details in this comprehensive form. All fields marked with * are required.',
        targetPosition: const Offset(20, 150),
        targetSize: const Size(350, 200),
        icon: Icons.edit,
      ),
      TourStep(
        title: 'Document Upload',
        description: 'Upload your resume, cover letter, and other supporting documents here.',
        targetPosition: const Offset(20, 370),
        targetSize: const Size(350, 80),
        icon: Icons.upload_file,
      ),
      TourStep(
        title: 'Save Progress',
        description: 'Your progress is automatically saved, but you can also save drafts manually.',
        targetPosition: const Offset(20, 470),
        targetSize: const Size(100, 40),
        icon: Icons.save,
      ),
      TourStep(
        title: 'Submit Application',
        description: 'Once everything is complete, submit your application for review.',
        targetPosition: const Offset(270, 470),
        targetSize: const Size(100, 40),
        icon: Icons.send,
      ),
    ];
  }

  static List<TourStep> getHRDashboardTour() {
    return [
      TourStep(
        title: 'Application Queue',
        description: 'Review pending applications and manage your hiring pipeline from here.',
        targetPosition: const Offset(20, 150),
        targetSize: const Size(350, 150),
        icon: Icons.queue,
      ),
      TourStep(
        title: 'Analytics Overview',
        description: 'Monitor hiring metrics, conversion rates, and team performance.',
        targetPosition: const Offset(20, 320),
        targetSize: const Size(170, 120),
        icon: Icons.analytics,
      ),
      TourStep(
        title: 'Team Collaboration',
        description: 'Collaborate with other team members and share feedback on candidates.',
        targetPosition: const Offset(200, 320),
        targetSize: const Size(170, 120),
        icon: Icons.group,
      ),
      TourStep(
        title: 'Quick Actions',
        description: 'Perform common tasks like scheduling interviews or sending messages quickly.',
        targetPosition: const Offset(20, 460),
        targetSize: const Size(350, 60),
        icon: Icons.speed,
      ),
    ];
  }
}

// Onboarding progress tracker
class OnboardingProgress {
  final int currentStep;
  final int totalSteps;
  final String currentSection;
  final double completionPercentage;

  OnboardingProgress({
    required this.currentStep,
    required this.totalSteps,
    required this.currentSection,
  }) : completionPercentage = (currentStep / totalSteps) * 100;

  bool get isComplete => currentStep >= totalSteps;
  
  OnboardingProgress nextStep() {
    return OnboardingProgress(
      currentStep: currentStep + 1,
      totalSteps: totalSteps,
      currentSection: currentSection,
    );
  }
}