import 'package:flutter/material.dart';
import '../../core/models/workout_model.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class GuidanceDetailScreen extends StatelessWidget {
  final SafetyGuide guide;
  const GuidanceDetailScreen({super.key, required this.guide});

  bool get _isWarning => guide.title.toLowerCase().contains('warning');
  bool get _hasVideo => guide.category == 'Warm-up' || guide.category == 'Cool-down';

  // Parses "1. Title - 2 minutes" style lines from the mock content into
  // (title, meta) pairs, matching the numbered step lists in the mockups.
  List<(String, String)> get _steps {
    final lines = guide.content.split('\n').where((l) => RegExp(r'^\s*\d+\.').hasMatch(l));
    return lines.map((l) {
      final cleaned = l.replaceFirst(RegExp(r'^\s*\d+\.\s*'), '');
      final parts = cleaned.split(' - ');
      return (parts.first.trim(), parts.length > 1 ? parts[1].trim() : '');
    }).toList();
  }

  // Splits the Warning Signs paragraph into individual symptom bullets.
  List<String> get _warningItems {
    return guide.content
        .split(RegExp(r':\s*|,\s*(?=[a-z])'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && !s.toLowerCase().startsWith('stop exercising'))
        .map((s) => s[0].toUpperCase() + s.substring(1))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Protocol Detail View')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(guide.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(guide.category, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 16),
                  if (_hasVideo)
                    Container(
                      height: 170,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(16)),
                      child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 52)),
                    ),
                  if (_hasVideo) const SizedBox(height: 16),
                  if (_isWarning) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('Stop Exercising If You Experience',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._warningItems.map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text(w, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                            const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    )),
                    const SizedBox(height: 8),
                    AppCard(
                      color: AppColors.brandTeal.withValues(alpha: 0.06),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.brandTeal, size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text('When in doubt, stop and consult a healthcare professional.',
                                style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                          ),
                        ],
                      ),
                    ),
                  ] else if (steps.isNotEmpty) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${steps.length} Steps', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 10),
                          for (int i = 0; i < steps.length; i++) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 13,
                                  backgroundColor: AppColors.brandTeal,
                                  child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(steps[i].$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      if (steps[i].$2.isNotEmpty)
                                        Text(steps[i].$2, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (i != steps.length - 1)
                              Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Container(width: 1.5, height: 18, color: AppColors.border),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ] else ...[
                    AppCard(
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.brandTeal),
                          const SizedBox(width: 12),
                          Expanded(child: Text(guide.content, style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        const Icon(Icons.shield, color: Colors.white, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(fontSize: 12, color: Colors.white, height: 1.4),
                              children: [
                                TextSpan(text: 'Remember: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: 'Safety comes first. Progress slowly and stay consistent.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                label: _isWarning ? 'Back to Safety Content' : 'I Understand & Accept',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
