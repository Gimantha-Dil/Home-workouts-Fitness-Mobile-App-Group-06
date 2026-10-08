import 'package:flutter/material.dart';
import '../../core/models/workout_model.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/exercise_lottie_widget.dart';
import '../../shared/widgets/exercise_video_player.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  final Exercise exercise;
  const ExerciseDetailsScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  int _tab = 0;

  final _steps = const [
    ('Starting Setup', 'Start in a kneeling position on the mat with hands slightly wider than shoulder-width, palms firmly planted.'),
    ('Core & Spinal Alignment', 'Keep your back straight, ribcage tucked, and engage your core to form a smooth diagonal line from head to knees.'),
    ('Controlled Descent', 'Lower your chest smoothly towards the floor until elbows bend to approximately 90 degrees, inhaling steadily.'),
    ('Explosive Press', 'Push firmly through the palms to rise back to starting position, exhaling with power at the top of movement.'),
  ];

  @override
  Widget build(BuildContext context) {
    final hasVideo = widget.exercise.videoUrl != null && widget.exercise.videoUrl!.isNotEmpty;

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
        title: const Text('Active Workout Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: const [
          NotificationIconButton(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.exercise.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const Row(
                        children: [
                          Icon(Icons.volume_up_outlined, size: 18, color: AppColors.textSecondary),
                          SizedBox(width: 8),
                          Icon(Icons.fullscreen, size: 20, color: AppColors.textSecondary),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _badge('Bodyweight', const Color(0xFFCCFBF1), AppColors.brandTeal),
                      const SizedBox(width: 6),
                      _badge('${widget.exercise.sets} sets • ${widget.exercise.reps} reps', const Color(0xFFE0F2FE), AppColors.info),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Real MP4 Exercise Video Streaming Player or Placeholder
                  if (hasVideo)
                    ExerciseVideoPlayer(
                      videoUrl: widget.exercise.videoUrl!,
                      title: widget.exercise.name,
                    )
                  else
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.videocam_off_outlined, color: AppColors.textSecondary, size: 40),
                          const SizedBox(height: 8),
                          Text(widget.exercise.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          const Text('No video available yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Lottie 60 FPS Exercise Motion Animation
                  const ExerciseLottieWidget(height: 100),
                  const SizedBox(height: 16),

                  // Tabs: Instructions | Trainer Tips
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _tab == 0 ? AppColors.brandTeal : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _tab == 0 ? AppColors.brandTeal : const Color(0xFFE5E7EB)),
                            ),
                            child: Text('Instructions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _tab == 0 ? Colors.white : AppColors.textSecondary)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _tab == 1 ? AppColors.brandTeal : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _tab == 1 ? AppColors.brandTeal : const Color(0xFFE5E7EB)),
                            ),
                            child: Text('Trainer Tips', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _tab == 1 ? Colors.white : AppColors.textSecondary)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Instructions Tab or Trainer Tips Tab
                  if (_tab == 0) ...[
                    if (widget.exercise.instructions.isNotEmpty)
                      ...widget.exercise.instructions.asMap().entries.map((entry) {
                        final i = entry.key + 1;
                        final text = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.brandTeal,
                                child: Text('$i', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Step $i', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                    else
                      ..._steps.asMap().entries.map((entry) {
                        final i = entry.key + 1;
                        final (title, desc) = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.brandTeal,
                                child: Text('$i', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ] else ...[
                    // Trainer Tips tab
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFEDD5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: Color(0xFFD97706), size: 18),
                              SizedBox(width: 8),
                              Text('Trainer Pro Tip', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB45309), fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.exercise.tip.isNotEmpty
                                ? widget.exercise.tip
                                : 'Keep your back straight, ribcage tucked, and engage your core throughout the movement to prevent lower back strain.',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF78350F), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Physio Safety Advisory Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified, color: AppColors.brandTeal, size: 16),
                            const SizedBox(width: 6),
                            const Text('Physio Safety Advisory', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(6)),
                              child: const Text('MEDICAL REVIEW', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Keep neck in neutral alignment by staring 6 inches forward on the mat. Avoid flaring elbows out at 90° angles; aim for an arrow-shaped 45° tuck to protect shoulder rotators.',
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('PRIMARY TARGET MUSCLES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  const Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _MuscleChip(label: 'Chest (Pectoralis Major)', color: AppColors.brandTeal),
                      _MuscleChip(label: 'Triceps Brachii', color: AppColors.info),
                      _MuscleChip(label: 'Anterior Deltoid', color: AppColors.warning),
                      _MuscleChip(label: 'Core Stabilizers', color: AppColors.purple),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Rest Period Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: AppColors.brandTeal, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Rest Period Between Sets', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              Text('Recommended 45 seconds for beginners', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(8)),
                          child: const Text('⏱ 0:45', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
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
                label: 'Start This Exercise →',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textCol)),
    );
  }
}

class _MuscleChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MuscleChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}