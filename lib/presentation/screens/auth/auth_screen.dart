// lib/presentation/screens/auth/auth_screen.dart
// Beautiful glassmorphism login screen with Google Sign-In

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim  = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Stack(
          children: [
            // ── Background decorative circles ──
            _buildDecorativeBackground(),

            // ── Main content ──
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    // Logo + brand
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: _buildBrandSection(),
                    ),
                    const Spacer(flex: 2),
                    // Sign-in card
                    SlideTransition(
                      position: _slideAnim,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: _buildSignInCard(),
                      ),
                    ),
                    const Spacer(flex: 1),
                    // Footer
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: _buildFooter(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeBackground() {
    return Stack(
      children: [
        // Top-right glow
        Positioned(
          top: -80, right: -80,
          child: Container(
            width: 300, height: 300,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.accentRadial,
            ),
          ),
        ),
        // Bottom-left glow
        Positioned(
          bottom: -60, left: -60,
          child: Container(
            width: 240, height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.secondary.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Centre subtle grid pattern
        Positioned.fill(
          child: Opacity(
            opacity: 0.03,
            child: CustomPaint(painter: _GridPainter()),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandSection() {
    return Column(
      children: [
        // Logo mark
        Container(
          width: 88, height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.accent, Color(0xFFE8A0A8)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accent.withOpacity(0.4),
                blurRadius: 24, offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'D',
              style: TextStyle(
                fontSize: 48, fontWeight: FontWeight.w900,
                color: Colors.white, letterSpacing: -2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'DAVA STORE',
          style: TextStyle(
            fontSize: 34, fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          AppConstants.appTagline,
          style: TextStyle(
            fontSize: 14, color: AppTheme.textMuted,
            letterSpacing: 2, fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInCard() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return GlassContainer(
          borderRadius: AppConstants.radiusXl,
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome Back',
                style: AppTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in to continue shopping',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Error message
              if (auth.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    border: Border.all(
                      color: AppTheme.error.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    auth.errorMessage!,
                    style: const TextStyle(
                      color: AppTheme.error, fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Google Sign-In button
              _buildGoogleButton(auth),

              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.divider)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Exclusive access',
                      style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppTheme.divider)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'DAVA Store uses Google Sign-In only\nfor enhanced security.',
                style: TextStyle(
                  color: AppTheme.textMuted, fontSize: 12,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoogleButton(AuthProvider auth) {
    if (auth.isLoading) {
      return Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.glassWhite,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: const Center(
          child: SizedBox(
            width: 24, height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppTheme.accent),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => context.read<AuthProvider>().signInWithGoogle(),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google logo SVG colours simulated with coloured squares
            _googleLogo(),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(
                color: Color(0xFF3C4043),
                fontSize: 15, fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _googleLogo() {
    return SizedBox(
      width: 22, height: 22,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'By continuing you agree to our',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Terms of Service',
                style: TextStyle(fontSize: 12, color: AppTheme.accent),
              ),
            ),
            const Text(' & ',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 12, color: AppTheme.accent),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Custom Painters ─────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.width / 2;
    final r = size.width / 2;

    // Simplified G logo
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(c, c), radius: r),
      -1.57, 3.14, false, paint..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.2
        ..color = const Color(0xFF4285F4),
    );

    paint
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(c, c), radius: r),
      1.57, 1.05, false,
      paint..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.2
        ..color = const Color(0xFF34A853),
    );

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(c, c), radius: r),
      2.62, 1.05, false,
      paint..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.2
        ..color = const Color(0xFFFBBC05),
    );

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(c, c), radius: r),
      3.67, 1.62, false,
      paint..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.2
        ..color = const Color(0xFFEA4335),
    );
  }
  @override
  bool shouldRepaint(_) => false;
}
