import 'dart:async';
import 'package:desafio_monalisa/presentation/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _gradientAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _gradientAnimation = ColorTween(
      begin: const Color(0xFF1E3A8A),
      end: const Color(0xFF1E40AF),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _gradientAnimation.value ?? const Color(0xFF1E3A8A),
                  Color.lerp(
                        _gradientAnimation.value ?? const Color(0xFF1E3A8A),
                        const Color(0xFF1E40AF),
                        0.5,
                      ) ??
                      const Color(0xFF1E40AF),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Animate(
                    effects: [
                      ScaleEffect(
                        begin: const Offset(0.4, 0.4),
                        end: const Offset(1.0, 1.0),
                        curve: Curves.easeOutBack,
                        duration: 1200.ms,
                      ),
                      FadeEffect(duration: 800.ms, curve: Curves.easeOut),
                    ],
                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.cover,

                      scale: 2,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Animate(
                    effects: [
                      FadeEffect(duration: 800.ms, delay: 1200.ms),
                      ScaleEffect(
                        duration: 1500.ms,
                        delay: 1200.ms,
                        begin: const Offset(0.7, 0.7),
                        end: const Offset(1.0, 1.0),
                        curve: Curves.easeOutBack,
                      ),
                      RotateEffect(
                        duration: 2000.ms,
                        delay: 1200.ms,
                        begin: 0,
                        end: 1.0,
                      ),
                    ],
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFA637),
                      ),
                      strokeWidth: 3,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Animate(
                    effects: [
                      FadeEffect(
                        duration: 600.ms,
                        delay: 1800.ms,
                        curve: Curves.easeOut,
                      ),
                    ],
                    child: const Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
