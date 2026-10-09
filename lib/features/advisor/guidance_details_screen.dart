import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_network_image.dart';

class GuidanceDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const GuidanceDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final title = item['title']?.toString() ?? 'Exercise Precautions';
    final category = item['category']?.toString() ?? 'General Safety';
    final content = item['content']?.toString() ?? '';
    final authorName = item['authorName']?.toString() ?? item['author']?.toString() ?? 'Dr. Medical Advisor';
    final imageUrl = item['imageUrl']?.toString() ?? item['image_url']?.toString();

    final lines = content.isNotEmpty
        ? content.split('\n').where((l) => l.trim().isNotEmpty).toList()
        : [
      'Listen to your body: If you feel pain, dizziness, or unusual fatigue, stop immediately.',
      'Avoid overexertion: Start slow and increase intensity gradually.',
      'Stay hydrated: Drink water before, during, and after exercise.',
      'Use proper form: Correct technique helps prevent joint injury.',
      'Wear suitable clothing: Choose comfortable, breathable workout clothes and supportive shoes.',
      'Consult a professional: Seek advice if you have underlying joint or heart conditions.',
    ];

    final iconsList = [
      Icons.hearing_outlined,
      Icons.speed_outlined,
      Icons.water_drop_outlined,
      Icons.accessibility_new_outlined,
      Icons.checkroom_outlined,
      Icons.medical_services_outlined,
      Icons.favorite_border_outlined,
    ];

    final colorsList = [
      AppColors.danger,
      AppColors.warning,
      AppColors.info,
      AppColors.brandTeal,
      AppColors.purple,
      AppColors.success,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Header Protocol Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFFCCFBF1),
                          child: Icon(Icons.verified, color: AppColors.brandTeal, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(category.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal, letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text('By $authorName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 2),
                              const Text('SLMC Certified Medical Guidance', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(6)),
                          child: const Text('UPDATED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hero Banner
                  Container(
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF475569), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'FOUNDATION • FORM • LONGEVITY',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Uploaded Diagram/Image (if available)
                  if (imageUrl != null && imageUrl.trim().isNotEmpty && imageUrl.startsWith('http')) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.white,
                        child: AppNetworkImage(
                          url: imageUrl,
                          width: double.infinity,
                          height: 180,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Guidance Steps List
                  ...lines.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final text = entry.value;

                    final String numStr = (idx + 1).toString().padLeft(2, '0');
                    final IconData icon = iconsList[idx % iconsList.length];
                    final Color color = colorsList[idx % colorsList.length];

                    // Parse header title if contains colon (e.g. "Listen to your body: If you feel...")
                    final parts = text.split(':');
                    final stepTitle = parts.length > 1 ? parts[0].trim() : 'Guideline $numStr';
                    final stepDesc = parts.length > 1 ? parts.sublist(1).join(':').trim() : text;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: color.withValues(alpha: 0.12),
                              child: Icon(icon, color: color, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(stepTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(stepDesc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(numStr, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Accept Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandTeal,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✓ Clinical safety guidance acknowledged: "$title"'),
                      backgroundColor: AppColors.brandTeal,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.check, size: 18, color: Colors.white),
                label: const Text('I understand & accept', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
