import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';
import 'goal_selection_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  String _ageRange = '18 - 25 years';
  String _gender = 'Male';
  String _heightUnit = 'cm';
  String _weightUnit = 'kg';
  String _fitnessLevel = 'Beginner';
  final _heightController = TextEditingController(text: '160');
  final _weightController = TextEditingController(text: '80');

  bool get _isHeightValid {
    final h = double.tryParse(_heightController.text.trim());
    return h != null && h >= 30 && h <= 300;
  }

  bool get _isWeightValid {
    final w = double.tryParse(_weightController.text.trim());
    return w != null && w >= 10 && w <= 400;
  }

  @override
  void initState() {
    super.initState();
    _heightController.addListener(() => setState(() {}));
    _weightController.addListener(() => setState(() {}));
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final docSnap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (docSnap.exists && docSnap.data() != null) {
        final data = docSnap.data()!;
        final profile = data['profile'] as Map<String, dynamic>?;

        if (profile != null) {
          final heightRaw = profile['height']?.toString() ?? '160 cm';
          final weightRaw = profile['weight']?.toString() ?? '80 kg';

          final heightParts = heightRaw.trim().split(' ');
          final heightNum = heightParts.first;
          final heightUnit = heightParts.length > 1 ? heightParts.last : 'cm';

          final weightParts = weightRaw.trim().split(' ');
          final weightNum = weightParts.first;
          final weightUnit = weightParts.length > 1 ? weightParts.last : 'kg';

          setState(() {
            _ageRange = profile['ageRange']?.toString() ?? '18 - 25 years';
            _gender = profile['gender']?.toString() ?? 'Male';
            _fitnessLevel = profile['fitnessLevel']?.toString() ?? 'Beginner';
            _heightUnit = heightUnit;
            _weightUnit = weightUnit;
            _heightController.text = heightNum;
            _weightController.text = weightNum;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading existing profile biometrics: $e');
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    if (!_isHeightValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid height value (e.g. 165).')),
      );
      return false;
    }

    if (!_isWeightValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid weight value (e.g. 68).')),
      );
      return false;
    }

    return true;
  }

  Future<void> _saveProfileData() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'profile': {
            'ageRange': _ageRange,
            'gender': _gender,
            'height': '${_heightController.text.trim()} $_heightUnit',
            'weight': '${_weightController.text.trim()} $_weightUnit',
            'fitnessLevel': _fitnessLevel,
            'updatedAt': FieldValue.serverTimestamp(),
          }
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        title: const Text('Profile Calibration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(20)),
            child: const Row(
              children: [
                Text('STEP 1 OF 2', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                SizedBox(width: 4),
                Text('Profile Setup', style: TextStyle(fontSize: 10, color: AppColors.brandTeal)),
                SizedBox(width: 4),
                Icon(Icons.check_circle, size: 12, color: AppColors.brandTeal),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tell us about yourself', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              const Text(
                'This helps us create a personalized experience and safe, clinical-grade workout thresholds for you.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 16),
              // Calibration Banner Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFF0FDF4), Color(0xFFE0F2FE)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCCFBF1)),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.brandTeal,
                      child: Icon(Icons.person, color: Colors.white, size: 22),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PERSONALIZED METRICS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandTeal, letterSpacing: 0.5)),
                          SizedBox(height: 2),
                          Text('Baseline Calibration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Adapts workout targets instantly', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Age Bracket
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Age Bracket', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('Standard Safety Band', style: TextStyle(fontSize: 10, color: AppColors.brandTeal, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _ageRange,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  prefixIcon: Icon(Icons.airline_seat_recline_normal, color: AppColors.brandTeal, size: 18),
                ),
                items: const ['13 - 17 years', '18 - 25 years', '26 - 35 years', '36 - 45 years', '46+ years']
                    .map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (v) => setState(() => _ageRange = v!),
              ),
              const SizedBox(height: 16),
              // Biological Identity
              const Text('Biological Identity (For Calorie Calibration)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _gender = 'Male'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _gender == 'Male' ? AppColors.brandTeal : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Male', style: TextStyle(fontWeight: FontWeight.bold, color: _gender == 'Male' ? Colors.white : AppColors.textPrimary)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _gender = 'Female'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _gender == 'Female' ? AppColors.brandTeal : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Female', style: TextStyle(fontWeight: FontWeight.bold, color: _gender == 'Female' ? Colors.white : AppColors.textPrimary)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Height & Weight Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text('Height', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Icon(_isHeightValid ? Icons.check_circle : Icons.error_outline,
                                    size: 14, color: _isHeightValid ? AppColors.success : AppColors.danger),
                              ],
                            ),
                            Row(
                              children: [
                                _unitChip('cm', _heightUnit == 'cm', () => setState(() => _heightUnit = 'cm')),
                                _unitChip('ft', _heightUnit == 'ft', () => setState(() => _heightUnit = 'ft')),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _isHeightValid ? AppColors.brandTeal : AppColors.danger),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text('Weight', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Icon(_isWeightValid ? Icons.check_circle : Icons.error_outline,
                                    size: 14, color: _isWeightValid ? AppColors.success : AppColors.danger),
                              ],
                            ),
                            Row(
                              children: [
                                _unitChip('kg', _weightUnit == 'kg', () => setState(() => _weightUnit = 'kg')),
                                _unitChip('lbs', _weightUnit == 'lbs', () => setState(() => _weightUnit = 'lbs')),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _isWeightValid ? AppColors.brandTeal : AppColors.danger),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Baseline Fitness Level
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Baseline Fitness Level', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('Select baseline', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 10),
              _fitnessOption('Beginner', 'New to physical training or returning from break', Icons.adjust),
              const SizedBox(height: 8),
              _fitnessOption('Intermediate', 'Active 2-3 sessions/week with solid stamina', Icons.swap_calls),
              const SizedBox(height: 8),
              _fitnessOption('Advanced', 'Consistent heavy resistance or high-intensity conditioning', Icons.bolt),
              const SizedBox(height: 16),
              // Clinical Privacy Standard Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user, color: AppColors.brandTeal, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Clinical Privacy Standard', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                          SizedBox(height: 2),
                          Text('Your metrics are strictly encrypted and used solely by the exertion engine to ensure safe heart rate thresholds.',
                              style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Next →',
                onPressed: () async {
                  if (!_validateInputs()) return;

                  await _saveProfileData();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const GoalSelectionScreen()),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('Step 1 of 2 • You can calibrate these anytime in Profile Settings', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _unitChip(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        margin: const EdgeInsets.only(left: 2),
        decoration: BoxDecoration(
          color: active ? AppColors.brandTeal : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: active ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }

  Widget _fitnessOption(String title, String desc, IconData icon) {
    final active = _fitnessLevel == title;
    return GestureDetector(
      onTap: () => setState(() => _fitnessLevel = title),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? AppColors.brandTeal : const Color(0xFFE5E7EB), width: active ? 1.5 : 1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: active ? AppColors.brandTeal.withValues(alpha: 0.1) : const Color(0xFFF3F4F6),
              child: Icon(icon, size: 16, color: active ? AppColors.brandTeal : AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: active ? AppColors.brandTeal : AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(active ? Icons.check_circle : Icons.add_circle_outline, size: 20, color: active ? AppColors.brandTeal : AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
