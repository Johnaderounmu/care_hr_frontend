import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import 'animated_care_logo.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final String? subtitle;

  const SplashScreen({
    super.key,
    this.onComplete,
    this.subtitle,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _subtitleController;
  late AnimationController _backgroundController;

  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _backgroundOpacity;

  bool _logoAnimationComplete = false;

  @override
  void initState() {
    super.initState();

    // Set the status bar style for splash screen
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _subtitleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeIn),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOut),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeIn),
    );

    _backgroundOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _startBackgroundAnimation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _startBackgroundAnimation() {
    _backgroundController.forward();
  }

  void _onLogoAnimationComplete() {
    setState(() {
      _logoAnimationComplete = true;
    });
    _startTextAnimations();
  }

  Future<void> _startTextAnimations() async {
    // Start title animation
    await _titleController.forward();
    
    // Start subtitle animation with a slight delay
    await Future.delayed(const Duration(milliseconds: 200));
    await _subtitleController.forward();
    
    // Wait a bit more, then complete
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Restore system UI style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.backgroundLight,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(_backgroundOpacity.value),
                  AppColors.secondary.withOpacity(_backgroundOpacity.value * 0.8),
                  Colors.white.withOpacity(1 - _backgroundOpacity.value * 0.5),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Animated Care Logo
                  AnimatedCareLogo(
                    size: 140,
                    onAnimationComplete: _onLogoAnimationComplete,
                  ),

                  const SizedBox(height: 40),

                  // App Title
                  AnimatedBuilder(
                    animation: _titleController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _titleSlide,
                        child: FadeTransition(
                          opacity: _titleOpacity,
                          child: Text(
                            AppStrings.appName,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: _logoAnimationComplete 
                                  ? AppColors.primary 
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  AnimatedBuilder(
                    animation: _subtitleController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _subtitleOpacity,
                        child: Text(
                          widget.subtitle ?? 'Connecting Care with Careers',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _logoAnimationComplete
                                ? AppColors.mutedLight
                                : Colors.white.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),

                  const Spacer(flex: 2),

                  // Loading indicator (only show after logo animation)
                  if (_logoAnimationComplete)
                    FadeTransition(
                      opacity: _subtitleOpacity,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 40),
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Powered by Flutter (subtle)
                  if (_logoAnimationComplete)
                    FadeTransition(
                      opacity: _subtitleOpacity,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          'Professional Care Solutions',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedLight.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}