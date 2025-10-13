import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/animations/custom_animations.dart';
import '../../../../core/services/navigation_service.dart';

class OnboardingData {
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;
  final Color backgroundColor;
  final List<OnboardingFeature> features;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
    required this.backgroundColor,
    this.features = const [],
  });
}

class OnboardingFeature {
  final String title;
  final String description;
  final IconData icon;

  OnboardingFeature({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingScreen extends StatefulWidget {
  final String userType; // 'applicant' or 'hr'

  const OnboardingScreen({
    super.key,
    required this.userType,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _progressController;
  
  int _currentPage = 0;
  bool _isLastPage = false;
  
  late List<OnboardingData> _onboardingData;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _initializeOnboardingData();
    _progressController.forward();
  }

  void _initializeOnboardingData() {
    if (widget.userType == 'applicant') {
      _onboardingData = [
        OnboardingData(
          title: 'Welcome to Care HR!',
          description: 'Your journey to finding the perfect job starts here. Let\'s explore what makes Care HR special.',
          imagePath: 'assets/images/welcome.png',
          icon: Icons.waving_hand,
          backgroundColor: AppColors.primary,
          features: [
            OnboardingFeature(
              title: 'Easy Applications',
              description: 'Apply to jobs with just a few taps',
              icon: Icons.touch_app,
            ),
            OnboardingFeature(
              title: 'Real-time Updates',
              description: 'Get notified about your application status',
              icon: Icons.notifications_active,
            ),
          ],
        ),
        OnboardingData(
          title: 'Apply with Confidence',
          description: 'Upload your documents, fill out applications, and track your progress all in one place.',
          imagePath: 'assets/images/apply.png',
          icon: Icons.description,
          backgroundColor: AppColors.secondary,
          features: [
            OnboardingFeature(
              title: 'Document Management',
              description: 'Upload and organize all your documents',
              icon: Icons.folder_open,
            ),
            OnboardingFeature(
              title: 'Application Tracking',
              description: 'Monitor your application status',
              icon: Icons.track_changes,
            ),
          ],
        ),
        OnboardingData(
          title: 'Stay Connected',
          description: 'Receive notifications about interviews, updates, and important messages from HR teams.',
          imagePath: 'assets/images/connect.png',
          icon: Icons.connect_without_contact,
          backgroundColor: AppColors.accentInfo,
          features: [
            OnboardingFeature(
              title: 'Interview Scheduling',
              description: 'Book and manage your interview slots',
              icon: Icons.calendar_today,
            ),
            OnboardingFeature(
              title: 'Direct Messaging',
              description: 'Communicate directly with HR teams',
              icon: Icons.message,
            ),
          ],
        ),
        OnboardingData(
          title: 'Ready to Start?',
          description: 'You\'re all set to begin your job search journey. Let\'s find your dream job together!',
          imagePath: 'assets/images/success.png',
          icon: Icons.rocket_launch,
          backgroundColor: AppColors.success,
        ),
      ];
    } else {
      _onboardingData = [
        OnboardingData(
          title: 'Welcome HR Manager!',
          description: 'Streamline your hiring process with powerful tools designed for modern HR teams.',
          imagePath: 'assets/images/hr_welcome.png',
          icon: Icons.admin_panel_settings,
          backgroundColor: AppColors.primary,
          features: [
            OnboardingFeature(
              title: 'Efficient Hiring',
              description: 'Manage applications and candidates effectively',
              icon: Icons.people,
            ),
            OnboardingFeature(
              title: 'Analytics Dashboard',
              description: 'Track hiring metrics and performance',
              icon: Icons.analytics,
            ),
          ],
        ),
        OnboardingData(
          title: 'Manage Applications',
          description: 'Review applications, schedule interviews, and collaborate with your team seamlessly.',
          imagePath: 'assets/images/hr_manage.png',
          icon: Icons.assignment,
          backgroundColor: AppColors.secondary,
          features: [
            OnboardingFeature(
              title: 'Application Review',
              description: 'Efficiently review and filter candidates',
              icon: Icons.rate_review,
            ),
            OnboardingFeature(
              title: 'Team Collaboration',
              description: 'Work together with your HR team',
              icon: Icons.group_work,
            ),
          ],
        ),
        OnboardingData(
          title: 'Data & Insights',
          description: 'Access powerful analytics and reports to make data-driven hiring decisions.',
          imagePath: 'assets/images/hr_analytics.png',
          icon: Icons.insights,
          backgroundColor: AppColors.accentWarning,
          features: [
            OnboardingFeature(
              title: 'Hiring Reports',
              description: 'Generate comprehensive hiring reports',
              icon: Icons.assessment,
            ),
            OnboardingFeature(
              title: 'Performance Metrics',
              description: 'Track team and process performance',
              icon: Icons.trending_up,
            ),
          ],
        ),
        OnboardingData(
          title: 'Let\'s Get Started!',
          description: 'Everything is ready for you to transform your hiring process. Welcome aboard!',
          imagePath: 'assets/images/hr_success.png',
          icon: Icons.celebration,
          backgroundColor: AppColors.success,
        ),
      ];
    }
    _isLastPage = _onboardingData.length == 1;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishOnboarding() {
    // Save onboarding completion status
    Navigator.of(context).pushReplacementNamed(
      widget.userType == 'applicant' ? '/applicant-dashboard' : '/hr-dashboard',
    );
  }

  void _skipOnboarding() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Onboarding?'),
        content: const Text('Are you sure you want to skip the tutorial? You can always access it later from settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _finishOnboarding();
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress and skip button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progress indicator
                  Expanded(
                    child: Row(
                      children: List.generate(_onboardingData.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 4),
                          height: 4,
                          width: (MediaQuery.of(context).size.width - 100) / _onboardingData.length,
                          decoration: BoxDecoration(
                            color: index <= _currentPage 
                                ? AppColors.primary 
                                : AppColors.primary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ),
                  
                  // Skip button
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                    _isLastPage = index == _onboardingData.length - 1;
                  });
                  _animationController.reset();
                  _animationController.forward();
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(
                    data: _onboardingData[index],
                    animationController: _animationController,
                  );
                },
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  AnimatedOpacity(
                    opacity: _currentPage > 0 ? 1.0 : 0.3,
                    duration: const Duration(milliseconds: 300),
                    child: AnimatedButton(
                      onPressed: _currentPage > 0 ? _previousPage : null,
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Previous',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Next/Get Started button
                  AnimatedButton(
                    onPressed: _nextPage,
                    backgroundColor: _onboardingData[_currentPage].backgroundColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isLastPage ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _isLastPage ? Icons.check : Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
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
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final AnimationController animationController;

  const _OnboardingPage({
    required this.data,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Icon with animation
          AnimationHelpers.scaleIn(
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: data.backgroundColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                data.icon,
                size: 80,
                color: data.backgroundColor,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Title with typewriter effect
          AnimationHelpers.fadeIn(
            duration: const Duration(milliseconds: 500),
            child: TypewriterText(
              text: data.title,
              duration: const Duration(milliseconds: 50),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description with fade in
          AnimationHelpers.fadeIn(
            duration: const Duration(milliseconds: 700),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Features list (if available)
          if (data.features.isNotEmpty) ...[
            ...AnimationHelpers.createStaggeredList(
              children: data.features.map((feature) => _FeatureCard(
                feature: feature,
                accentColor: data.backgroundColor,
              )).toList(),
              itemDelay: const Duration(milliseconds: 150),
            ),
          ],
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final OnboardingFeature feature;
  final Color accentColor;

  const _FeatureCard({
    required this.feature,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              feature.icon,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Guided tour overlay for existing screens
class GuidedTourOverlay extends StatefulWidget {
  final Widget child;
  final List<TourStep> tourSteps;
  final VoidCallback? onTourComplete;
  final bool showTour;

  const GuidedTourOverlay({
    super.key,
    required this.child,
    required this.tourSteps,
    this.onTourComplete,
    this.showTour = false,
  });

  @override
  State<GuidedTourOverlay> createState() => _GuidedTourOverlayState();
}

class _GuidedTourOverlayState extends State<GuidedTourOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentStep = 0;
  bool _isTourActive = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    if (widget.showTour) {
      _startTour();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startTour() {
    setState(() {
      _isTourActive = true;
      _currentStep = 0;
    });
    _animationController.forward();
  }

  void _nextStep() {
    if (_currentStep < widget.tourSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _finishTour();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _finishTour() {
    _animationController.reverse().then((_) {
      setState(() {
        _isTourActive = false;
      });
      widget.onTourComplete?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isTourActive)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _animationController.value,
                child: _TourOverlay(
                  step: widget.tourSteps[_currentStep],
                  currentStep: _currentStep,
                  totalSteps: widget.tourSteps.length,
                  onNext: _nextStep,
                  onPrevious: _previousStep,
                  onClose: _finishTour,
                ),
              );
            },
          ),
      ],
    );
  }
}

class TourStep {
  final String title;
  final String description;
  final Offset targetPosition;
  final Size targetSize;
  final IconData? icon;

  TourStep({
    required this.title,
    required this.description,
    required this.targetPosition,
    required this.targetSize,
    this.icon,
  });
}

class _TourOverlay extends StatelessWidget {
  final TourStep step;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onClose;

  const _TourOverlay({
    required this.step,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onPrevious,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.7),
      child: Stack(
        children: [
          // Highlight area
          Positioned(
            left: step.targetPosition.dx - 8,
            top: step.targetPosition.dy - 8,
            child: Container(
              width: step.targetSize.width + 16,
              height: step.targetSize.height + 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          
          // Tooltip
          Positioned(
            left: 24,
            right: 24,
            bottom: 100,
            child: AnimationHelpers.slideInFromDirection(
              direction: SlideDirection.bottomToTop,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (step.icon != null) ...[
                          Icon(
                            step.icon,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            step.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onClose,
                          icon: const Icon(Icons.close),
                          iconSize: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${currentStep + 1} of $totalSteps',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Row(
                          children: [
                            if (currentStep > 0)
                              TextButton(
                                onPressed: onPrevious,
                                child: const Text('Previous'),
                              ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: onNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                currentStep < totalSteps - 1 ? 'Next' : 'Finish',
                              ),
                            ),
                          ],
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
    );
  }
}