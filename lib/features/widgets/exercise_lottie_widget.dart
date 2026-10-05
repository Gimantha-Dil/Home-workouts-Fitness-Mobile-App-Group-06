import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_theme.dart';

class ExerciseLottieWidget extends StatelessWidget {
  final String? lottieUrl;
  final double height;

  const ExerciseLottieWidget({
    super.key,
    this.lottieUrl,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    if (lottieUrl != null && lottieUrl!.isNotEmpty) {
      return Lottie.network(
        lottieUrl!,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCCFBF1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.directions_run_outlined, size: 38, color: AppColors.brandTeal),
          SizedBox(height: 6),
          Text('60 FPS Motion Animation', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
        ],
      ),
    );
  }
}
