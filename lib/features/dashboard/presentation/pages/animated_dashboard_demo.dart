import 'package:flutter/material.dart';
import '../../../../core/animations/custom_animations.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/constants/app_colors.dart';

class AnimatedDashboardDemo extends StatefulWidget {
  const AnimatedDashboardDemo({super.key});

  @override
  State<AnimatedDashboardDemo> createState() => _AnimatedDashboardDemoState();
}

class _AnimatedDashboardDemoState extends State<AnimatedDashboardDemo>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animation Demo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with typewriter effect
            AnimationHelpers.fadeIn(
              child: const TypewriterText(
                text: 'Welcome to Care HR App! ✨',
                duration: Duration(milliseconds: 100),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Animated cards with stagger
            ...AnimationHelpers.createStaggeredList(
              children: [
                _buildAnimatedMetricCard(
                  title: 'Total Applications',
                  value: 156,
                  icon: Icons.description,
                  color: AppColors.primary,
                ),
                _buildAnimatedMetricCard(
                  title: 'Pending Reviews',
                  value: 23,
                  icon: Icons.pending_actions,
                  color: AppColors.warning,
                ),
                _buildAnimatedMetricCard(
                  title: 'Interviews Scheduled',
                  value: 8,
                  icon: Icons.event,
                  color: AppColors.secondary,
                ),
                _buildAnimatedMetricCard(
                  title: 'Hired This Month',
                  value: 12,
                  icon: Icons.check_circle,
                  color: AppColors.success,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Interactive animation section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Interactive Animations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Animated button examples
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        AnimatedButton(
                          onPressed: () {
                            setState(() {
                              _showDetails = !_showDetails;
                            });
                          },
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          child: const Text(
                            'Toggle Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        PulseAnimation(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Text(
                              'Pulsing Button',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Loading animations
                    if (_showDetails) ...[
                      AnimationHelpers.slideInFromDirection(
                        direction: SlideDirection.bottomToTop,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Loading Animations:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const LoadingAnimation(
                                        color: AppColors.primary,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Spinner',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  Column(
                                    children: [
                                      AnimationHelpers.createBouncingDots(
                                        color: AppColors.secondary,
                                        size: 8,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Bouncing Dots',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  Column(
                                    children: [
                                      const PulsingDot(
                                        color: AppColors.warning,
                                        size: 16,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Pulsing Dot',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
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
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Navigation examples
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Navigation Animations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildNavigationButton(
                          'Slide Transition',
                          () => _navigateWithAnimation(AnimationType.slide),
                          AppColors.primary,
                        ),
                        _buildNavigationButton(
                          'Fade Transition',
                          () => _navigateWithAnimation(AnimationType.fade),
                          AppColors.secondary,
                        ),
                        _buildNavigationButton(
                          'Scale Transition',
                          () => _navigateWithAnimation(AnimationType.scale),
                          AppColors.accentInfo,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Progress animations
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Progress Animations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    AnimationHelpers.createAnimatedProgressBar(
                      progress: 0.75,
                      color: AppColors.primary,
                      duration: const Duration(milliseconds: 1500),
                    ),
                    const SizedBox(height: 8),
                    const Text('Application Progress: 75%'),
                    
                    const SizedBox(height: 24),
                    
                    AnimationHelpers.createAnimatedProgressBar(
                      progress: 0.45,
                      color: AppColors.secondary,
                      duration: const Duration(milliseconds: 1200),
                    ),
                    const SizedBox(height: 8),
                    const Text('Document Review: 45%'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedMetricCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return AnimatedCard(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimationHelpers.createAnimatedCounter(
                      value: value,
                      duration: const Duration(milliseconds: 1500),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    String text,
    VoidCallback onPressed,
    Color color,
  ) {
    return AnimatedButton(
      onPressed: onPressed,
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      borderRadius: BorderRadius.circular(20),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _navigateWithAnimation(AnimationType type) {
    NavigationService.pushWithAnimation(
      const _AnimationDemoPage(),
      type: type,
      duration: const Duration(milliseconds: 500),
    );
  }
}

class _AnimationDemoPage extends StatelessWidget {
  const _AnimationDemoPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animation Demo Page'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimationHelpers.scaleIn(
              child: const Icon(
                Icons.check_circle,
                size: 100,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 24),
            const TypewriterText(
              text: 'Animation transition complete!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            AnimatedButton(
              onPressed: () => Navigator.pop(context),
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              borderRadius: BorderRadius.circular(25),
              child: const Text(
                'Go Back',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}