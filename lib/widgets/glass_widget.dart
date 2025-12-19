import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable glassmorphism widget that creates a frosted glass effect
class GlassWidget extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Color? color;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassWidget({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.borderRadius,
    this.color,
    this.boxShadow,
    this.border,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (color ?? Colors.white).withValues(alpha: opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(20),
              border:
                  border ??
                  Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
              boxShadow:
                  boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Glass card widget with default styling
class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = GlassWidget(
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin,
      child: child,
    );

    if (width != null || height != null) {
      content = SizedBox(width: width, height: height, child: content);
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: content,
        ),
      );
    }

    return content;
  }
}
