import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

class StatusBadge extends StatelessWidget {
  final String status; // 'Under Budget', 'On Budget', 'Over Budget'

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String text = status;

    if (status == 'Under Budget') {
      bg = AppColors.statusUnderBudgetBg;
      fg = AppColors.statusUnderBudgetFg;
    } else if (status == 'On Budget') {
      bg = AppColors.statusOnBudgetBg;
      fg = AppColors.statusOnBudgetFg;
    } else if (status == 'Over Budget') {
      bg = AppColors.statusOverBudgetBg;
      fg = AppColors.statusOverBudgetFg;
    } else {
      bg = AppColors.chipSubSurface;
      fg = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Text(
        text,
        style: AppTypography.captionBadge.copyWith(color: fg),
      ),
    );
  }
}
