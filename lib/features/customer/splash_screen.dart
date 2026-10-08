import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF082721),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F544B),
              Color(0xFF082721),
              Color(0xFF04201D),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // Exact App Icon matching user reference image
              const _AppIconWidget(),
              const SizedBox(height: 32),
              // App Title
              const Text(
                'FitPulse',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              // Subtitle
              Text(
                'SMALL STEPS • BIG CHANGES',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12.5,
                  letterSpacing: 3.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppIconWidget extends StatelessWidget {
  const _AppIconWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF136E63), Color(0xFF053531)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(38),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2DD4BF).withValues(alpha: 0.35),
            blurRadius: 40,
            spreadRadius: 6,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF5EEAD4).withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Diagonal light sheen overlay matching user image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(38),
              child: CustomPaint(
                painter: _DiagonalSheenPainter(),
              ),
            ),
          ),
          // Background Heart shape
          Icon(
            Icons.favorite,
            color: const Color(0xFF14B8A6).withValues(alpha: 0.45),
            size: 78,
          ),
          // ECG Pulse Line + Glowing Dot
          CustomPaint(
            size: const Size(82, 44),
            painter: _EcgPulsePainter(),
          ),
        ],
      ),
    );
  }
}

class _DiagonalSheenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.2),
          Colors.white.withValues(alpha: 0.0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.65, 0)
      ..lineTo(0, size.height * 0.65)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EcgPulsePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5EEAD4)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // ECG pulse path matching the user reference image
    path.moveTo(0, h * 0.5);
    path.lineTo(w * 0.22, h * 0.5);
    path.lineTo(w * 0.38, h * 0.12); // peak
    path.lineTo(w * 0.52, h * 0.88); // trough
    path.lineTo(w * 0.68, h * 0.35);
    path.lineTo(w * 0.82, h * 0.5);
    path.lineTo(w, h * 0.5);

    canvas.drawPath(path, paint);

    // Glowing white dot on the top peak
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotGlow = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final peakPoint = Offset(w * 0.38, h * 0.12);
    canvas.drawCircle(peakPoint, 8, dotGlow);
    canvas.drawCircle(peakPoint, 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
