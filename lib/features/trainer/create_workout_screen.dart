import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'publish_workout_screen.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  int _step = 0;

  // Step 1 - workout details
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _targetLevel = 'Beginner';
  String _duration = '20 min';
  String _goal = 'Weight Loss';

  // Step 2 - exercise
  final _exerciseNameController = TextEditingController();
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '10');
  final _restController = TextEditingController(text: '60');
  String _exerciseDifficulty = 'Beginner';

  // Step 3 - instructions
  final List<TextEditingController> _instructionControllers = [TextEditingController(), TextEditingController()];
  final _tipController = TextEditingController();

  // Step 4 - video
  bool _videoAttached = false;

  void _next() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PublishWorkoutScreen(
            title: _titleController.text.isEmpty ? 'New Workout' : _titleController.text,
            level: _targetLevel,
            duration: _duration,
          ),
        ),
      );
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Create New Workout', 'Add Exercise', 'Exercise Instructions', 'Upload Video'];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(titles[_step]), leading: BackButton(onPressed: () => _step == 0 ? Navigator.of(context).pop() : _back())),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  Text('Step ${_step + 1} of 4', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(titles[_step], style: const TextStyle(fontSize: 11, color: AppColors.brandTeal, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(4, (i) {
                  final active = i <= _step;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i != 3 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: active ? AppColors.brandTeal : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStep(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(child: PrimaryButton(label: 'Previous', outlined: true, onPressed: _back)),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(child: PrimaryButton(label: _step == 3 ? 'Next' : 'Next', onPressed: _next)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String s) => Padding(padding: const EdgeInsets.only(bottom: 6, top: 12), child: Text(s, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)));

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Workout Title *'),
            TextField(controller: _titleController, decoration: const InputDecoration(hintText: 'e.g. Beginner Full Body')),
            _label('Description *'),
            TextField(controller: _descController, maxLines: 3, maxLength: 500, decoration: const InputDecoration(hintText: 'Brief description of the workout...')),
            _label('Target Level'),
            Row(
              children: ['Beginner', 'Intermediate', 'Advanced'].map((l) => Expanded(child: _chip(l, _targetLevel, (v) => setState(() => _targetLevel = v)))).toList(),
            ),
            _label('Duration (minutes) *'),
            DropdownButtonFormField<String>(
              initialValue: _duration,
              items: ['15 min', '20 min', '25 min', '30 min', '45 min'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => setState(() => _duration = v!),
            ),
            _label('Goal'),
            DropdownButtonFormField<String>(
              initialValue: _goal,
              items: ['Weight Loss', 'Build Strength', 'Improve Fitness', 'Stay Healthy', 'Increase Flexibility']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _goal = v!),
            ),
            const SizedBox(height: 20),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Exercise Name *'),
            TextField(controller: _exerciseNameController, decoration: const InputDecoration(hintText: 'e.g. Push Ups')),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_label('Sets *'), TextField(controller: _setsController, keyboardType: TextInputType.number)],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_label('Reps *'), TextField(controller: _repsController, keyboardType: TextInputType.number)],
                  ),
                ),
              ],
            ),
            _label('Rest Time (seconds) *'),
            TextField(controller: _restController, keyboardType: TextInputType.number),
            _label('Difficulty Level'),
            Row(
              children: ['Beginner', 'Intermediate', 'Advanced'].map((l) => Expanded(child: _chip(l, _exerciseDifficulty, (v) => setState(() => _exerciseDifficulty = v)))).toList(),
            ),
            const SizedBox(height: 20),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < _instructionControllers.length; i++) ...[
              _label('Step ${i + 1}'),
              TextField(controller: _instructionControllers[i], decoration: InputDecoration(hintText: 'Instruction step ${i + 1}')),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _instructionControllers.add(TextEditingController())),
                icon: const Icon(Icons.add),
                label: const Text('Add Step'),
              ),
            ),
            _label('Tips'),
            TextField(controller: _tipController, maxLines: 2, decoration: const InputDecoration(hintText: 'Keep your back straight...')),
            const SizedBox(height: 20),
          ],
        );
      case 3:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _videoAttached = true),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.trainerPrimary.withOpacity(0.4), style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_videoAttached ? Icons.check_circle : Icons.cloud_upload_outlined, color: AppColors.trainerPrimary, size: 36),
                    const SizedBox(height: 8),
                    Text(_videoAttached ? 'Video attached' : 'Drag & drop video file here', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    if (!_videoAttached)
                      OutlinedButton(onPressed: () => setState(() => _videoAttached = true), child: const Text('Choose File')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Supported formats: MP4, MOV (Max 100MB)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 20),
          ],
        );
    }
  }

  Widget _chip(String label, String selected, ValueChanged<String> onSelect) {
    final active = selected == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onSelect(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.trainerPrimary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? AppColors.trainerPrimary : Colors.grey.shade300),
          ),
          child: Text(label, style: TextStyle(color: active ? Colors.white : AppColors.textSecondary, fontSize: 12)),
        ),
      ),
    );
  }
}
