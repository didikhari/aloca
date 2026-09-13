import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double ratio; // 0.0 to 1.0+
  final Color color;
  final double height;

  const CustomProgressBar({
    super.key,
    required this.ratio,
    required this.color,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final clampedRatio = ratio.clamp(0.0, 1.0);

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: clampedRatio,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
