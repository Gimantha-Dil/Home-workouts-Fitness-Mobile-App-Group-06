import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'create_workout_screen.dart';
import 'edit_workout_screen.dart';
import 'trainer_profile_screen.dart';
import 'workout_management_screen.dart';

class TrainerDashboardScreen extends StatelessWidget {
  const TrainerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header App Bar matching Image 2
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Greeting & Profile Status Header
                  _buildGreetingHeader(),
                  const SizedBox(height: 16),

                  // Hero "CREATE NEW WORKOUT" Banner
                  _buildCreateWorkoutBanner(context),
                  const SizedBox(height: 16),

                  // Stat Cards Row (12 Total Built, 9 Live Catalog, 3 Reviewing)
                  _buildStatCardsRow(),
                  const SizedBox(height: 16),

                  // Catalog Live Rate Card
                  _buildCatalogLiveRateCard(),
                  const SizedBox(height: 16),

                  // FitPulse FastTrack Review SLA Card
                  _buildFastTrackReviewCard(),
                  const SizedBox(height: 20),

                  // Recent Activity Section Header
                  _buildRecentActivityHeader(context),
                  const SizedBox(height: 12),

                  // Activity Item 1: Beginner Full Body
                  _buildActivityCard1(context),
                  const SizedBox(height: 12),

                  // Activity Item 2: Upper Body Strength
                  _buildActivityCard2(context),
                  const SizedBox(height: 12),

                  // Activity Item 3: HIIT Cardio Interval
                  _buildActivityCard3(context),
                  const SizedBox(height: 16),

                  // Trainer Quick Links Card
                  _buildTrainerQuickLinksCard(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Round back button
          InkWell(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0xFF334155)),
            ),
          ),

          // FitPulse Logo Title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.brandTeal,
                ),
                child: const Icon(Icons.favorite_outline, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'FitPulse',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D9488),
                      height: 1.1,
                    ),
                  ),
                  const Text(
                    'TRAINER STUDIO',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F766E),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Profile circle icon on right -> Navigates to TrainerProfileScreen
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TrainerProfileScreen()),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF007A78),
              ),
              child: const Icon(Icons.person_outline, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingHeader() {
    return Row(
      children: [
        // Avatar with verified badge
        Stack(
          children: [
            ClipOval(
              child: Image.network(
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop',
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 52,
                  height: 52,
                  color: AppColors.brandTeal,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 10, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good morning, Alex!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Studio Overview • 42 Athletes Online',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreateWorkoutBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF0284C7)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x400D9488),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateWorkoutScreen()),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x33FFFFFF),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'CREATE NEW WORKOUT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0x38FFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x4DFFFFFF)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.bolt, color: Colors.white, size: 14),
                    SizedBox(width: 3),
                    Text(
                      'Builder 2.0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCardsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            value: '12',
            label: 'Total Built',
            tag: '+2 mo',
            tagBg: const Color(0xFFECFDF5),
            tagTextColor: const Color(0xFF047857),
            icon: Icons.fitness_center,
            iconColor: const Color(0xFF0D9488),
            barColor: const Color(0xFF0D9488),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatBox(
            value: '9',
            label: 'Live Catalog',
            tag: '98% ★',
            tagBg: const Color(0xFFFEF3C7),
            tagTextColor: const Color(0xFFD97706),
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF10B981),
            barColor: const Color(0xFF34D399),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatBox(
            value: '3',
            label: 'Reviewing',
            tag: 'In QA',
            tagBg: const Color(0xFFFEF3C7),
            tagTextColor: const Color(0xFFB45309),
            icon: Icons.emoji_events_outlined,
            iconColor: const Color(0xFFD97706),
            barColor: const Color(0xFFFBBF24),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required String value,
    required String label,
    required String tag,
    required Color tagBg,
    required Color tagTextColor,
    required IconData icon,
    required Color iconColor,
    required Color barColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 18, color: iconColor),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: tagTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 46,
            height: 3.5,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogLiveRateCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFF059669),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Catalog Live Rate',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      '75% of your workout programs are published',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Text(
                '75%',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF0D9488),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: 75,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0D9488), Color(0xFF0284C7)],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: 15,
                    child: Container(color: const Color(0xFF3B82F6)),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: 10,
                    child: Container(color: const Color(0xFFF59E0B)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _LegendItem(color: Color(0xFF0D9488), label: '9 Published'),
              _LegendItem(color: Color(0xFF3B82F6), label: '3 In QA'),
              _LegendItem(color: Color(0xFFF59E0B), label: '2 Drafts'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFastTrackReviewCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: Color(0xFF059669),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'FitPulse FastTrack Review',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Workouts submitted for moderation are clinically reviewed & verified within 4 hours.',
                  style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: const Text(
              'SLA: 4h',
              style: TextStyle(
                color: Color(0xFF059669),
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Text(
                '4',
                style: TextStyle(
                  color: Color(0xFF047857),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WorkoutManagementScreen()),
            );
          },
          child: const Text(
            'View All >',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF0D9488),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard1(BuildContext context) {
    return _buildActivityCardContainer(
      imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400&auto=format&fit=crop',
      durationTag: '30m',
      title: 'Beginner Full Body',
      statusBadgeText: 'DRAFT',
      statusBadgeBg: const Color(0xFFFEF3C7),
      statusBadgeTextColor: const Color(0xFFD97706),
      subtitleLine1: 'Level: Beginner • 12 exercises • 30 min',
      subtitleLine2: '🕒 Edited 2 hours ago',
      subtitle2Color: const Color(0xFF78350F),
      bottomBanner: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('✏️ ', style: TextStyle(fontSize: 10)),
            Text(
              'Missing video on Block 3',
              style: TextStyle(
                color: Color(0xFFC2410C),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      actionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00897B),
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(72, 32),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EditWorkoutScreen()),
          );
        },
        child: const Text(
          'Continue',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildActivityCard2(BuildContext context) {
    return _buildActivityCardContainer(
      imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400&auto=format&fit=crop',
      durationTag: '35m',
      title: 'Upper Body Strength',
      statusBadgeText: '✔ PUBLISHED',
      statusBadgeBg: const Color(0xFFD1FAE5),
      statusBadgeTextColor: const Color(0xFF059669),
      subtitleLine1: 'Level: Intermediate • 10 exercises • 35 min',
      subtitleLine2: '👥 148 athlete completions',
      subtitle2Color: const Color(0xFF64748B),
      bottomBanner: Row(
        children: const [
          Text('📈 ', style: TextStyle(fontSize: 10)),
          Text(
            '+24 completions today',
            style: TextStyle(
              color: Color(0xFF059669),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actionButton: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0D9488),
          side: const BorderSide(color: Color(0xFF99F6E4), width: 1.2),
          minimumSize: const Size(72, 32),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (ctx) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Upper Body Strength Metrics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• Total Completions: 148 Athletes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('• Average Rating: 4.9 ★ (82 reviews)', style: TextStyle(fontSize: 12, color: Color(0xFF0D9488))),
                  SizedBox(height: 4),
                  Text('• Today\'s Growth: +24 completions (+18% velocity)', style: TextStyle(fontSize: 12, color: Color(0xFF059669))),
                ],
              ),
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.bar_chart, size: 14, color: Color(0xFF0D9488)),
            SizedBox(width: 4),
            Text(
              'Metrics',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard3(BuildContext context) {
    return _buildActivityCardContainer(
      imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400&auto=format&fit=crop',
      durationTag: '25m',
      title: 'HIIT Cardio Interva',
      statusBadgeText: '🔄 UNDER REVIEW',
      statusBadgeBg: const Color(0xFFE0F2FE),
      statusBadgeTextColor: const Color(0xFF0284C7),
      subtitleLine1: 'Level: Intermediate • 8 exercises • 25 min',
      subtitleLine2: '↗ Submitted yesterday at 4:30 PM',
      subtitle2Color: const Color(0xFF64748B),
      bottomBanner: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF0284C7),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'Quality & Form audit in progress',
            style: TextStyle(
              color: Color(0xFF0284C7),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE0F2FE),
          foregroundColor: const Color(0xFF0284C7),
          elevation: 0,
          minimumSize: const Size(68, 32),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EditWorkoutScreen()),
          );
        },
        child: const Text(
          'Preview',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildActivityCardContainer({
    required String imageUrl,
    required String durationTag,
    required String title,
    required String statusBadgeText,
    required Color statusBadgeBg,
    required Color statusBadgeTextColor,
    required String subtitleLine1,
    required String subtitleLine2,
    required Color subtitle2Color,
    required Widget bottomBanner,
    required Widget actionButton,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 56,
                        height: 56,
                        color: const Color(0xFFE2E8F0),
                        child: const Icon(Icons.fitness_center, color: Color(0xFF0D9488)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xA6000000),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        durationTag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusBadgeBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusBadgeText,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              color: statusBadgeTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitleLine1,
                      style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitleLine2,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: subtitle2Color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: bottomBanner),
              const SizedBox(width: 8),
              actionButton,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrainerQuickLinksCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Trainer Quick Links',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Jump straight into asset library or client chats',
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎬 Video Asset Library loaded (Supabase CDN)'),
                  backgroundColor: AppColors.brandTeal,
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.smart_display_outlined,
                color: Color(0xFF059669),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('💬 Client Chats portal loaded!'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Color(0xFF0284C7),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}

