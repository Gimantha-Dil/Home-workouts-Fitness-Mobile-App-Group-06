import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/workout_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/common_widgets.dart';
import 'create_workout_screen.dart';
import 'edit_workout_screen.dart';
import 'trainer_profile_screen.dart';
import 'trainer_shell.dart';

class WorkoutManagementScreen extends StatefulWidget {
  const WorkoutManagementScreen({super.key});

  @override
  State<WorkoutManagementScreen> createState() => _WorkoutManagementScreenState();
}

class _WorkoutManagementScreenState extends State<WorkoutManagementScreen> {
  int _tab = 0;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const TrainerShell()),
              );
            }
          },
        ),
        title: const Row(
          children: [
            Icon(Icons.monitor_heart_outlined, color: AppColors.brandTeal, size: 22),
            SizedBox(width: 6),
            Text('FitPulse', style: TextStyle(color: AppColors.brandTeal, fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(width: 6),
            _Badge(text: 'TRAINER', color: AppColors.brandTeal),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TrainerProfileScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Workout>>(
          stream: SupabaseService.streamWorkoutsFromSupabase(),
          builder: (context, snapshot) {
            final docs = snapshot.data ?? [];

            var filtered = docs;
            if (_tab == 1) {
              filtered = filtered.where((w) => w.isPublished).toList();
            } else if (_tab == 2) {
              filtered = filtered.where((w) => w.status.toLowerCase() == 'draft').toList();
            } else if (_tab == 3) {
              filtered = filtered.where((w) => w.status.toLowerCase() == 'under review').toList();
            }

            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              filtered = filtered.where((w) => w.title.toLowerCase().contains(q) || w.level.toLowerCase().contains(q)).toList();
            }

            final totalRoutines = docs.length;
            final publishedCount = docs.where((w) => w.isPublished).length;
            final draftCount = docs.where((w) => w.status.toLowerCase() == 'draft').length;
            final reviewCount = docs.where((w) => w.status.toLowerCase() == 'under review').length;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('My Workouts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandTeal,
                              minimumSize: const Size(90, 32),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateWorkoutScreen())),
                            icon: const Icon(Icons.add, size: 14),
                            label: const Text('Create', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text('Manage curriculum & live routines from Supabase DB', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 16),

                      // Summary Badges
                      Row(
                        children: [
                          Expanded(child: _SummaryBox(title: 'ROUTINES', value: '$totalRoutines', tag: 'Total', color: AppColors.brandTeal)),
                          const SizedBox(width: 8),
                          Expanded(child: _SummaryBox(title: 'PUBLISHED', value: '$publishedCount', tag: 'Live', color: AppColors.success)),
                          const SizedBox(width: 8),
                          Expanded(child: _SummaryBox(title: 'DRAFTS', value: '$draftCount', tag: 'Building', color: AppColors.warning)),
                        ],
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search routines, tags, levels...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Tabs
                      Row(
                        children: [
                          Expanded(child: _tabBtn('All ($totalRoutines)', 0)),
                          const SizedBox(width: 4),
                          Expanded(child: _tabBtn('Published ($publishedCount)', 1)),
                          const SizedBox(width: 4),
                          Expanded(child: _tabBtn('Draft ($draftCount)', 2)),
                          const SizedBox(width: 4),
                          Expanded(child: _tabBtn('Review ($reviewCount)', 3)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Center(child: CircularProgressIndicator())
                      else if (filtered.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(30),
                            child: Text('No workouts found in Supabase DB.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ),
                        )
                      else
                        ...filtered.map((w) {
                          Color statusColor = AppColors.success;
                          if (w.status.toLowerCase() == 'draft') statusColor = AppColors.warning;
                          if (w.status.toLowerCase() == 'under review') statusColor = AppColors.info;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppCard(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      AppNetworkImage(
                                        url: w.imageUrl,
                                        width: 48,
                                        height: 48,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(w.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                _Badge(text: '• ${w.status.toUpperCase()}', color: statusColor),
                                              ],
                                            ),
                                            Text('Level: ${w.level} • ${w.exercises.length} exercises • ${w.durationMinutes} min',
                                                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _Badge(text: w.goal, color: AppColors.brandTeal),
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(60, 28),
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          side: const BorderSide(color: AppColors.brandTeal),
                                        ),
                                        onPressed: () => Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => EditWorkoutScreen(workout: w)),
                                        ),
                                        icon: const Icon(Icons.edit_outlined, size: 12, color: AppColors.brandTeal),
                                        label: const Text('Edit', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandTeal)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _tabBtn(String label, int index) {
    final active = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.brandTeal : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppColors.brandTeal : const Color(0xFFE5E7EB)),
        ),
        child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: active ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final String value;
  final String tag;
  final Color color;

  const _SummaryBox({required this.title, required this.value, required this.tag, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(tag, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
