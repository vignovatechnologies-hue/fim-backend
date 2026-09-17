import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();

    // Navigate to next screen after splash
    Timer(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        context.go('/dashboard');
      } else {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1E),
      body: Stack(
        children: [
          // Background Gradient & Ambient Glows
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF020B1E),
                  Color(0xFF05173B),
                  Color(0xFF082255),
                  Color(0xFF041029),
                ],
                stops: [0.0, 0.35, 0.75, 1.0],
              ),
            ),
          ),

          // Ambient Light Beams & Arcs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00D2FF).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Safe Area Screen Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Stack(
                children: [
                  // Top Right Tagline: Smarter Money Brighter Tomorrow
                  Positioned(
                    top: 24,
                    right: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Smarter Money',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7DD3FC).withValues(alpha: 0.9),
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Brighter Tomorrow',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7DD3FC).withValues(alpha: 0.9),
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Floating Glass Tiles (from Reference Image 2)
                  // 1. Top-Left Bar Chart Tile
                  Positioned(
                    top: 100,
                    left: 28,
                    child: _buildGlassTile(
                      icon: const Icon(Icons.bar_chart, color: Color(0xFF38BDF8), size: 24),
                    ),
                  ),

                  // 2. Middle-Left ₹ Rupee Tile
                  Positioned(
                    top: 270,
                    left: 20,
                    child: _buildGlassTile(
                      child: const Text(
                        '₹',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                  ),

                  // 3. Top-Right Pie Chart Tile
                  Positioned(
                    top: 190,
                    right: 24,
                    child: _buildGlassTile(
                      icon: const Icon(Icons.pie_chart, color: Color(0xFF38BDF8), size: 24),
                    ),
                  ),

                  // 4. Middle-Right Wallet Tile
                  Positioned(
                    top: 350,
                    right: 28,
                    child: _buildGlassTile(
                      icon: const Icon(LucideIcons.wallet, color: Color(0xFF38BDF8), size: 24),
                    ),
                  ),

                  // 5. Bottom-Right Shield Check Tile
                  Positioned(
                    bottom: 220,
                    right: 36,
                    child: _buildGlassTile(
                      icon: const Icon(LucideIcons.shield_check, color: Color(0xFF38BDF8), size: 24),
                    ),
                  ),

                  // Center Emblem & Typography & Loading
                  Center(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),

                          // Glowing Center Squircle Emblem
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(36),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF0A2E68),
                                    Color(0xFF031435),
                                  ],
                                ),
                                border: Border.all(
                                  color: const Color(0xFF00E5FF),
                                  width: 2.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                                    blurRadius: 36,
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF1D61F2).withValues(alpha: 0.6),
                                    blurRadius: 48,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(34),
                                child: Image.asset(
                                  'assets/images/splash_emblem.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(LucideIcons.trending_up, color: Color(0xFF00E5FF), size: 48),
                                        SizedBox(height: 8),
                                        Text(
                                          'FIM',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Brand Typography
                          Text(
                            'FINANCIAL',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4.5,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'INTELLIGENCE',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 5.0,
                              color: const Color(0xFF38BDF8),
                              shadows: [
                                Shadow(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 28,
                                height: 1.5,
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.7),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'MANAGER',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 3.5,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                              Container(
                                width: 28,
                                height: 1.5,
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.7),
                              ),
                            ],
                          ),
                          const SizedBox(height: 52),

                          // Glowing Loading Spinner
                          SizedBox(
                            width: 38,
                            height: 38,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.2,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                              backgroundColor: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Loading...',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.8,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Graphic Wave & Indicators
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Text(
                          'PLAN   •   TRACK   •   ACHIEVE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3.5,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 28,
                              height: 3.5,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 34,
                              height: 4.5,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5FF),
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 28,
                              height: 3.5,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTile({Widget? icon, Widget? child}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF0A2E68).withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(child: icon ?? child),
    );
  }
}

