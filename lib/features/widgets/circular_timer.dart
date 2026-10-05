import 'package:flutter/material.dart';

class CircularTimer extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final String label;
  final Color color;

  const CircularTimer({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.label,
    required this.color,
  });

  String get _formatted {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds == 0 ? 0.0 : remainingSeconds / totalSeconds;
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: CircularProgressIndicator(
              value: progress.clamp(0, 1),
              strokeWidth: 10,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_formatted, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
