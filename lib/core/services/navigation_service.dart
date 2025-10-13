import 'package:flutter/material.dart';
import '../animations/custom_animations.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<T?> pushWithAnimation<T extends Object?>(
    Widget page, {
    AnimationType type = AnimationType.slide,
    SlideDirection direction = SlideDirection.rightToLeft,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return Future.value(null);

    PageRouteBuilder<T> route;

    switch (type) {
      case AnimationType.slide:
        route = SlidePageTransition(
          child: page,
          direction: direction,
          duration: duration,
        );
        break;
      case AnimationType.fade:
        route = FadePageTransition(
          child: page,
          duration: duration,
        );
        break;
      case AnimationType.scale:
        route = ScalePageTransition(
          child: page,
          duration: duration,
        );
        break;
    }

    return Navigator.of(context).push<T>(route);
  }

  static Future<T?> pushReplacementWithAnimation<T extends Object?, TO extends Object?>(
    Widget page, {
    AnimationType type = AnimationType.slide,
    SlideDirection direction = SlideDirection.rightToLeft,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return Future.value(null);

    PageRouteBuilder<T> route;

    switch (type) {
      case AnimationType.slide:
        route = SlidePageTransition(
          child: page,
          direction: direction,
          duration: duration,
        );
        break;
      case AnimationType.fade:
        route = FadePageTransition(
          child: page,
          duration: duration,
        );
        break;
      case AnimationType.scale:
        route = ScalePageTransition(
          child: page,
          duration: duration,
        );
        break;
    }

    return Navigator.of(context).pushReplacement<T, TO>(route);
  }

  static void pop<T extends Object?>([T? result]) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    Navigator.of(context).pop<T>(result);
  }

  static bool canPop() {
    final context = navigatorKey.currentContext;
    if (context == null) return false;
    return Navigator.of(context).canPop();
  }
}

enum AnimationType {
  slide,
  fade,
  scale,
}

// Animation helpers for common UI patterns
class AnimationHelpers {
  // Staggered list animation
  static List<Widget> createStaggeredList({
    required List<Widget> children,
    Duration itemDelay = const Duration(milliseconds: 100),
    Duration animationDuration = const Duration(milliseconds: 300),
  }) {
    return List.generate(children.length, (index) {
      return AnimatedCard(
        duration: animationDuration,
        delay: index * itemDelay.inMilliseconds / 1000,
        child: children[index],
      );
    });
  }

  // Hero animation wrapper
  static Widget createHero({
    required String tag,
    required Widget child,
  }) {
    return Hero(
      tag: tag,
      child: child,
    );
  }

  // Animated counter
  static Widget createAnimatedCounter({
    required int value,
    Duration duration = const Duration(milliseconds: 1000),
    TextStyle? style,
  }) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      builder: (context, value, child) {
        return Text(
          value.toString(),
          style: style,
        );
      },
    );
  }

  // Animated progress bar
  static Widget createAnimatedProgressBar({
    required double progress,
    Duration duration = const Duration(milliseconds: 500),
    Color? color,
    Color? backgroundColor,
    double height = 4.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: progress),
      duration: duration,
      builder: (context, value, child) {
        return LinearProgressIndicator(
          value: value,
          color: color,
          backgroundColor: backgroundColor,
          minHeight: height,
        );
      },
    );
  }

  // Bouncing dot loading animation
  static Widget createBouncingDots({
    Color color = Colors.blue,
    double size = 8.0,
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: AlwaysStoppedAnimation(0.0),
          builder: (context, child) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: duration,
              builder: (context, value, child) {
                final animationValue = (value + index * 0.2) % 1.0;
                final scale = 0.5 + (0.5 * (1.0 - (animationValue * 2.0 - 1.0).abs()));
                
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: size * 0.2),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }

  // Slide in from direction
  static Widget slideInFromDirection({
    required Widget child,
    required SlideDirection direction,
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(
        begin: _getSlideOffset(direction),
        end: Offset.zero,
      ),
      duration: duration,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: offset,
          child: child,
        );
      },
      child: child,
    );
  }

  // Scale in animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = Duration.zero,
    Curve curve = Curves.elasticOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: child,
    );
  }

  // Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: child,
    );
  }

  // Rotation animation
  static Widget rotateIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    double turns = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: turns),
      duration: duration,
      builder: (context, turns, child) {
        return Transform.rotate(
          angle: turns * 2 * 3.14159,
          child: child,
        );
      },
      child: child,
    );
  }

  static Offset _getSlideOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.leftToRight:
        return const Offset(-100, 0);
      case SlideDirection.rightToLeft:
        return const Offset(100, 0);
      case SlideDirection.topToBottom:
        return const Offset(0, -100);
      case SlideDirection.bottomToTop:
        return const Offset(0, 100);
    }
  }
}

// Custom animation widgets for specific use cases
class PulsingDot extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const PulsingDot({
    super.key,
    this.size = 12.0,
    this.color = Colors.red,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final Duration duration;
  final TextStyle? style;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 50),
    this.style,
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration * widget.text.length,
      vsync: this,
    );

    _animation = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(_controller);

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          widget.text.substring(0, _animation.value),
          style: widget.style,
        );
      },
    );
  }
}