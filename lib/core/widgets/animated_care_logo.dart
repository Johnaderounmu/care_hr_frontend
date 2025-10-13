import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AnimatedCareLogo extends StatefulWidget {
  final double size;
  final bool autoStart;
  final VoidCallback? onAnimationComplete;

  const AnimatedCareLogo({
    super.key,
    this.size = 120,
    this.autoStart = true,
    this.onAnimationComplete,
  });

  @override
  State<AnimatedCareLogo> createState() => _AnimatedCareLogoState();
}

class _AnimatedCareLogoState extends State<AnimatedCareLogo>
    with TickerProviderStateMixin {
  late AnimationController _morphController;
  late AnimationController _careController;
  late AnimationController _pulseController;

  late Animation<double> _morphProgress;
  late Animation<double> _careOpacity;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    
    // Morph/scale animation for care elements
    _morphController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Care scene entrance animation
    _careController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Subtle pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _morphProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeInOut),
    );
    
    _careOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _careController, curve: Curves.easeIn),
    );
    
    _pulseScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.autoStart) {
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    _careController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startAnimation() async {
    // Skip Flutter F - go directly to care theme
    // Phase 1: Direct care scene entrance (0-1.5 seconds)
    await _careController.forward();
    
    // Phase 2: Gentle morph/scale effect (1.5-2.5 seconds)
    await _morphController.forward();
    
    // Phase 3: Start subtle pulse (2.5+ seconds)
    _pulseController.repeat(reverse: true);
    
    // Notify completion
    widget.onAnimationComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _morphController,
        _careController,
        _pulseController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseScale.value,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.8),
                        AppColors.secondary.withOpacity(0.9),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                
                // Care scene (main focus)
                Opacity(
                  opacity: _careOpacity.value,
                  child: Transform.scale(
                    scale: 0.8 + (_morphProgress.value * 0.2), // Subtle scale animation
                    child: _buildCareScene(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCareScene() {
    return SizedBox(
      width: widget.size * 0.6,
      height: widget.size * 0.6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Healthcare provider (person giving care)
          Positioned(
            left: widget.size * 0.05,
            top: widget.size * 0.1,
            child: Icon(
              Icons.person,
              size: widget.size * 0.2,
              color: Colors.white,
            ),
          ),
          
          // Care recipient
          Positioned(
            right: widget.size * 0.05,
            top: widget.size * 0.15,
            child: Icon(
              Icons.person_outline,
              size: widget.size * 0.18,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          
          // Heart symbol (care/love)
          Positioned(
            bottom: widget.size * 0.15,
            child: AnimatedBuilder(
              animation: _careController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (_careController.value * 0.3),
                  child: Icon(
                    Icons.favorite,
                    size: widget.size * 0.15,
                    color: Colors.red.shade200,
                  ),
                );
              },
            ),
          ),
          
          // Helping hands
          Positioned(
            left: widget.size * 0.2,
            bottom: widget.size * 0.05,
            child: Transform.rotate(
              angle: 0.3,
              child: Icon(
                Icons.pan_tool,
                size: widget.size * 0.1,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

