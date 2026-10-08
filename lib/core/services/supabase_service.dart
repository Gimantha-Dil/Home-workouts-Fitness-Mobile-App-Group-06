import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_role.dart';
import '../models/workout_model.dart';

/// Supabase Backend Integration (PostgreSQL DB, Storage Buckets, Auth)
class SupabaseService {
  // Production Supabase Project Config
  static const String supabaseUrl = 'https://ctguxkodnxxntloshlls.supabase.co';
  static const String supabasePublishableKey =
      'sb_publishable_16YzWxaZ-YIn4bCH1D4ZcA_gK67V4-2';

  static bool isInitialized = false;

  /// Initialize Supabase Flutter Client
  static Future<void> initializeSupabase() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabasePublishableKey, // replaces deprecated anonKey
      );
      isInitialized = true;
      debugPrint('⚡ Supabase Initialized Successfully with Live Project Keys!');
    } catch (e) {
      debugPrint('⚡ Supabase Initialization Note: $e');
    }
  }

  /// 📤 Storage: Upload MP4 Exercise Video directly to exercise-videos bucket
  static Future<String> uploadExerciseVideo({
    required String fileName,
    required List<int> videoBytes,
  }) async {
    try {
      if (!isInitialized) {
        await initializeSupabase();
      }

      // Clean file name to prevent special character path issues in Supabase Storage
      final cleanName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_\-\.]'), '_');

      // Upload directly to the root of 'exercise-videos' bucket with upsert enabled
      await Supabase.instance.client.storage
          .from('exercise-videos')
          .uploadBinary(
            cleanName,
            Uint8List.fromList(videoBytes),
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = Supabase.instance.client.storage
          .from('exercise-videos')
          .getPublicUrl(cleanName);

      debugPrint('🎬 Uploaded Video directly to Supabase Storage bucket exercise-videos: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('🎬 Supabase Storage Upload Error: $e');
      try {
        final fallbackName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
        await Supabase.instance.client.storage
            .from('exercise-videos')
            .uploadBinary(
              fallbackName,
              Uint8List.fromList(videoBytes),
              fileOptions: const FileOptions(upsert: true),
            );
        final fallbackUrl = Supabase.instance.client.storage
            .from('exercise-videos')
            .getPublicUrl(fallbackName);
        debugPrint('🎬 Uploaded Fallback Video to Supabase Storage: $fallbackUrl');
        return fallbackUrl;
      } catch (err) {
        debugPrint('🎬 Supabase Storage Fallback Error: $err');
      }
    }
    return '$supabaseUrl/storage/v1/object/public/exercise-videos/$fileName';
  }

  /// 📸 Storage: Upload User Profile Photo
  static Future<String> uploadUserPhoto({
    required String fileName,
    required List<int> photoBytes,
  }) async {
    try {
      if (isInitialized) {
        await Supabase.instance.client.storage
            .from('user-photos')
            .uploadBinary('avatars/$fileName', Uint8List.fromList(photoBytes));

        return Supabase.instance.client.storage
            .from('user-photos')
            .getPublicUrl('avatars/$fileName');
      }
    } catch (e) {
      debugPrint('📸 Supabase Photo Upload Note: $e');
    }
    return '$supabaseUrl/storage/v1/object/public/user-photos/avatars/$fileName';
  }

  /// 📑 Storage: Upload Trainer/Advisor Verification Documents
  static Future<String> uploadVerificationDoc({
    required String fileName,
    required List<int> docBytes,
  }) async {
    try {
      if (isInitialized) {
        await Supabase.instance.client.storage
            .from('verification-docs')
            .uploadBinary('docs/$fileName', Uint8List.fromList(docBytes));

        return Supabase.instance.client.storage
            .from('verification-docs')
            .getPublicUrl('docs/$fileName');
      }
    } catch (e) {
      debugPrint('📑 Supabase Doc Upload Note: $e');
    }
    return '$supabaseUrl/storage/v1/object/public/verification-docs/docs/$fileName';
  }

  /// 🗄️ Database: Save User Record
  static Future<bool> saveUserToSupabase({
    required String uid,
    required String name,
    required String email,
    required UserRole role,
  }) async {
    try {
      if (isInitialized) {
        await Supabase.instance.client.from('users').upsert({
          'id': uid,
          'name': name,
          'email': email,
          'role': role.name,
          'created_at': DateTime.now().toIso8601String(),
        });
        debugPrint('⚡ User saved to Supabase Database!');
        return true;
      }
    } catch (e) {
      debugPrint('⚡ Supabase User Save Note: $e');
    }
    return true;
  }

  /// 🗄️ Database: Save Workout Record to Supabase 'workouts' table
  static Future<bool> saveWorkoutToSupabase({
    Workout? workout,
    String? workoutId,
    String? title,
    String? level,
    int? durationMinutes,
    String? status,
    String? videoUrl,
  }) async {
    if (!isInitialized) {
      await initializeSupabase();
    }

    final rawId = (workout?.id != null && workout!.id.isNotEmpty)
        ? workout.id
        : (workoutId != null && workoutId.isNotEmpty ? workoutId : null);
    final id = rawId ?? 'w_${DateTime.now().millisecondsSinceEpoch}';

    final t = (workout?.title != null && workout!.title.isNotEmpty)
        ? workout.title
        : (title != null && title.isNotEmpty ? title : 'New Workout');

    final l = (workout?.level != null && workout!.level.isNotEmpty)
        ? workout.level
        : (level != null && level.isNotEmpty ? level : 'Beginner');

    final d = (workout != null && workout.durationMinutes > 0)
        ? workout.durationMinutes
        : (durationMinutes ?? 20);

    final s = (workout?.status != null && workout!.status.isNotEmpty)
        ? workout.status
        : (status != null && status.isNotEmpty ? status : 'published');

    final v = (workout?.videoUrl != null && workout!.videoUrl!.isNotEmpty)
        ? workout.videoUrl!
        : (videoUrl ?? '');

    try {
      final record = {
        'id': id,
        'title': t,
        'level': l,
        'duration_minutes': d,
        'status': s.toLowerCase(),
        'video_url': v,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await Supabase.instance.client
          .from('workouts')
          .upsert(record)
          .select();

      debugPrint('⚡ Saved workout "$t" (id: $id, video_url: $v) to Supabase Database table workouts! Response: $response');
      return true;
    } catch (e) {
      debugPrint('⚡ Supabase Workout Save Error: $e');
    }
    return true;
  }

  /// 🗄️ Database: Fetch all workouts from Supabase workouts table
  static Future<List<Workout>> fetchWorkoutsFromSupabase() async {
    try {
      if (isInitialized) {
        final List<dynamic> data = await Supabase.instance.client
            .from('workouts')
            .select()
            .order('created_at', ascending: false);

        debugPrint('⚡ Fetched ${data.length} records from Supabase workouts table');
        return data.map((map) => Workout.fromMap(Map<String, dynamic>.from(map))).toList();
      }
    } catch (e) {
      debugPrint('⚡ Supabase Fetch Workouts Note: $e');
    }
    return [];
  }

  /// 🗄️ Database: Realtime stream of workouts from Supabase
  static Stream<List<Workout>> streamWorkoutsFromSupabase() {
    try {
      if (isInitialized) {
        return Supabase.instance.client
            .from('workouts')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: false)
            .map((list) => list.map((map) => Workout.fromMap(map)).toList());
      }
    } catch (e) {
      debugPrint('⚡ Supabase Stream Workouts Note: $e');
    }
    return Stream.value([]);
  }

  /// 🗄️ Database: Update Workout Status
  static Future<bool> updateWorkoutStatusInSupabase({
    required String workoutId,
    required String status,
  }) async {
    try {
      if (isInitialized) {
        await Supabase.instance.client.from('workouts').update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', workoutId);
        return true;
      }
    } catch (e) {
      debugPrint('⚡ Supabase Update Workout Status Note: $e');
    }
    return true;
  }
}