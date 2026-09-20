import 'package:flutter/material.dart';
import '../../core/database/hive_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../dashboard/dashboard_screen.dart';
import '../onboarding/initial_setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  late Animation<double> _walletScale;
  late Animation<double> _walletOpacity;

  late Animation<double> _coinsOffset;
  late Animation<double> _coinsOpacity;

  late Animation<double> _flowProgress;

  late Animation<double> _dest1Scale;
  late Animation<double> _dest1Opacity;
  late Animation<double> _dest2Scale;
  late Animation<double> _dest2Opacity;
  late Animation<double> _dest3Scale;
  late Animation<double> _dest3Opacity;
  late Animation<double> _dest4Scale;
  late Animation<double> _dest4Opacity;

  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // 0.0 - 0.4s (0.0 to 0.16)
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.20, curve: Curves.easeOutBack),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.16, curve: Curves.easeIn),
      ),
    );

    // 0.3 - 0.8s (0.12 to 0.32)
    _walletScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.12, 0.32, curve: Curves.easeOutBack),
      ),
    );
    _walletOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.12, 0.28, curve: Curves.easeIn),
      ),
    );

    // 0.6 - 1.2s (0.24 to 0.48)
    _coinsOffset = Tween<double>(begin: -40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.24, 0.48, curve: Curves.easeInOutCubic),
      ),
    );
    _coinsOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 60,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.24, 0.48),
      ),
    );

    // 1.0 - 1.8s (0.40 to 0.72)
    _flowProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.72, curve: Curves.easeInOutCubic),
      ),
    );

    // 1.4 - 2.2s (0.56 to 0.88)
    _dest1Scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.56, 0.72, curve: Curves.easeOutBack),
      ),
    );
    _dest1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.56, 0.70, curve: Curves.easeIn),
      ),
    );

    _dest2Scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.60, 0.76, curve: Curves.easeOutBack),
      ),
    );
    _dest2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.60, 0.74, curve: Curves.easeIn),
      ),
    );

    _dest3Scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.64, 0.80, curve: Curves.easeOutBack),
      ),
    );
    _dest3Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.64, 0.78, curve: Curves.easeIn),
      ),
    );

    _dest4Scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.68, 0.84, curve: Curves.easeOutBack),
      ),
    );
    _dest4Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.68, 0.82, curve: Curves.easeIn),
      ),
    );

    // 2.0 - 2.5s (0.76 to 1.0)
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.76, 0.96, curve: Curves.easeIn),
      ),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.76, 0.96, curve: Curves.easeOutCubic),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    final periods = HiveService.getAllPeriods();
    final allocations = HiveService.getAllAllocations();
    final categories = HiveService.getAllCategories();
    final bool hasInitialPeriod =
        periods.isNotEmpty && allocations.isNotEmpty && categories.isNotEmpty;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            hasInitialPeriod
                ? const DashboardScreen()
                : const InitialSetupScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              children: [
                const SizedBox(height: AppSpacing.xl),

                // Top Logo
                Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xs + 2),
                          decoration: const BoxDecoration(
                            color: AppColors.brandTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: AppColors.brandPrimary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Aloca',
                          style: AppTypography.headingLarge.copyWith(
                            color: AppColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Center Graphic Area (Wallet + Flow Lines + Allocation Cards)
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animated Flow Lines Painter
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _AllocationFlowPainter(
                                progress: _flowProgress.value,
                                walletCenterY: constraints.maxHeight * 0.22,
                                gridCenterY: constraints.maxHeight * 0.62,
                                width: constraints.maxWidth,
                              ),
                            ),
                          ),

                          // Falling Coins (Moving into wallet)
                          Positioned(
                            top: constraints.maxHeight * 0.22 - 60 + _coinsOffset.value,
                            child: Opacity(
                              opacity: _coinsOpacity.value,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildCoinBadge('Rp'),
                                  const SizedBox(width: AppSpacing.sm),
                                  _buildCoinBadge('%'),
                                  const SizedBox(width: AppSpacing.sm),
                                  _buildCoinBadge('Rp'),
                                ],
                              ),
                            ),
                          ),

                          // Central Wallet / Income Source Node
                          Positioned(
                            top: constraints.maxHeight * 0.22 - 40,
                            child: Opacity(
                              opacity: _walletOpacity.value,
                              child: Transform.scale(
                                scale: _walletScale.value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.sm + 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceWhite,
                                    borderRadius: AppRadius.radiusLg,
                                    border: Border.all(
                                      color: AppColors.brandPrimary.withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.brandPrimary.withValues(alpha: 0.1),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.payments_outlined,
                                        color: AppColors.brandPrimary,
                                        size: 22,
                                      ),
                                      SizedBox(width: AppSpacing.sm),
                                      Text(
                                        '1 Penghasilan',
                                        style: AppTypography.bodyPrimary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 4 Allocation Destination Cards Grid (2x2)
                          Positioned(
                            top: constraints.maxHeight * 0.48,
                            left: AppSpacing.lg,
                            right: AppSpacing.lg,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Opacity(
                                        opacity: _dest1Opacity.value,
                                        child: Transform.scale(
                                          scale: _dest1Scale.value,
                                          child: _buildDestinationCard(
                                            title: 'Kebutuhan',
                                            color: AppColors.brandPrimary,
                                            icon: Icons.home_work_outlined,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Opacity(
                                        opacity: _dest2Opacity.value,
                                        child: Transform.scale(
                                          scale: _dest2Scale.value,
                                          child: _buildDestinationCard(
                                            title: 'Dana Darurat',
                                            color: AppColors.warningAmber,
                                            icon: Icons.shield_outlined,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Opacity(
                                        opacity: _dest3Opacity.value,
                                        child: Transform.scale(
                                          scale: _dest3Scale.value,
                                          child: _buildDestinationCard(
                                            title: 'Investasi',
                                            color: AppColors.infoBlueDark,
                                            icon: Icons.trending_up_outlined,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Opacity(
                                        opacity: _dest4Opacity.value,
                                        child: Transform.scale(
                                          scale: _dest4Scale.value,
                                          child: _buildDestinationCard(
                                            title: 'Tujuan Lain',
                                            color: const Color(0xFF8B5CF6),
                                            icon: Icons.stars_outlined,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Bottom Tagline
                SlideTransition(
                  position: _taglineSlide,
                  child: Opacity(
                    opacity: _taglineOpacity.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.xl,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Satu Penghasilan, Banyak Alokasi',
                            textAlign: TextAlign.center,
                            style: AppTypography.headingMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Plan • Allocate • Track',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.brandPrimary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCoinBadge(String label) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.brandPrimary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.brandPrimary.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.brandPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationCard({
    required String title,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md - 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.radiusCard,
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyPrimary.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter for drawing smooth branching flow lines from income node to destination cards
class _AllocationFlowPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final double walletCenterY;
  final double gridCenterY;
  final double width;

  _AllocationFlowPainter({
    required this.progress,
    required this.walletCenterY,
    required this.gridCenterY,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final startPoint = Offset(width / 2, walletCenterY + 20);

    // 4 Target positions relative to grid layout
    final leftX = AppSpacing.lg + (width - AppSpacing.lg * 2) * 0.25;
    final rightX = width - AppSpacing.lg - (width - AppSpacing.lg * 2) * 0.25;

    final row1Y = gridCenterY - 26;
    final row2Y = gridCenterY + 26;

    final destinations = [
      Offset(leftX, row1Y), // Kebutuhan
      Offset(rightX, row1Y), // Dana Darurat
      Offset(leftX, row2Y), // Investasi
      Offset(rightX, row2Y), // Tujuan Lain
    ];

    final colors = [
      AppColors.brandPrimary,
      AppColors.warningAmber,
      AppColors.infoBlueDark,
      const Color(0xFF8B5CF6),
    ];

    for (int i = 0; i < destinations.length; i++) {
      final dest = destinations[i];
      final color = colors[i];

      final paint = Paint()
        ..color = color.withValues(alpha: 0.35 * progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(startPoint.dx, startPoint.dy);

      // Smooth cubic bezier curve from start to destination
      final controlY1 = startPoint.dy + (dest.dy - startPoint.dy) * 0.4;
      final controlY2 = startPoint.dy + (dest.dy - startPoint.dy) * 0.6;

      path.cubicTo(
        startPoint.dx,
        controlY1,
        dest.dx,
        controlY2,
        dest.dx,
        dest.dy,
      );

      // Extract path metrics to draw animated progress length
      final pMetrics = path.computeMetrics().first;
      final extractPath = pMetrics.extractPath(0, pMetrics.length * progress);

      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AllocationFlowPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.walletCenterY != walletCenterY ||
        oldDelegate.gridCenterY != gridCenterY;
  }
}
