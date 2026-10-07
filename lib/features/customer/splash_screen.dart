import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              children: [
                const Spacer(flex: 3),
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.monitor_heart_outlined, color: Colors.white, size: 46),
                ),
                const SizedBox(height: 24),
                const Text(
                  'FitPulse',
                  style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'SMALL STEPS • BIG CHANGES',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, letterSpacing: 2),
                ),
                const Spacer(flex: 3),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final progress = _animation.value;
                    final percentage = (progress * 100).toInt();
                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Loading...', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                            Text('$percentage%', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
