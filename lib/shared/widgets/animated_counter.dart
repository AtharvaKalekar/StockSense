import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  final num value;
  final TextStyle? style;
  final Duration duration;
  final String? prefix;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 1200),
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        final pre = prefix ?? '';
        final suf = suffix ?? '';
        return Text(
          '$pre${val.toInt()}$suf',
          style: style ?? Theme.of(context).textTheme.headlineSmall,
        );
      },
    );
  }
}
