import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_role.dart';
import '../models/workout_model.dart';

/// Supabase Backend Integration (Storage Buckets, Database, Auth)
class SupabaseService {
  // Production Supabase Project Config
  static const String supabaseUrl = 'https://ctguxkodnxxntloshlls.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_16YzWxaZ-YIn4bCH1D4ZcA_gK67V4-2';

  static bool isInitialized = false;

  /// Initialize Supabase Flutter Client
  static Future<void> initializeSupabase() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
      isInitialized = true;
      debugPrint('⚡ Supabase Initialized Successfully with Live Project Keys!');
    } catch (e) {
      debugPrint('⚡ Supabase Initialization Note: $e');
    }
  }

  /// 📤 Supabase Storage Bucket: Upload MP4 Exercise Video
  static Future<String> uploadExerciseVideo({
    required String fileName,
    required List<int> videoBytes,
  }) async {
    try {
      if (isInitialized) {
        await Supabase.instance.client.storage
            .from('exercise-videos')
            .uploadBinary('mp4/$fileName', Uint8List.fromList(videoBytes));

        final publicUrl = Supabase.instance.client.storage
            .from('exercise-videos')
            .getPublicUrl('mp4/$fileName');

        debugPrint('🎬 Uploaded MP4 Video to Supabase CDN: $publicUrl');
        return publicUrl;
      }
    } catch (e) {
      debugPrint('🎬 Supabase Video Upload Note: $e');
    }
    return '$supabaseUrl/storage/v1/object/public/exercise-videos/mp4/$fileName';
  }

  /// 📸 Supabase Storage Bucket: Upload User Profile Photo
  static Future<String> uploadUserPhoto({
    required String fileName,
    required List<int> photoBytes,
  }) async {
    try {
      if (isInitialized) {
        await Supabase.instance.client.storage
            .from('user-photos')
            .uploadBinary('avatars/$fileName', Uint8List.fromList(photoBytes));

        final publicUrl = Supabase.instance.client.storage
            .from('user-photos')
            .getPublicUrl('avatars/$fileName');

        return publicUrl;
      }
    } catch (e) {
      debugPrint('📸 Supabase Photo Upload Note: $e');
    }
    return '$supabaseUrl/storage/v1/object/public/user-photos/avatars/$fileName';
  }

  /// 📑 Supabase Storage Bucket: Upload Trainer/Advisor Verification Documents (PDF / Images)
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

    final d = workout?.durationMinutes ?? durationMinutes ?? 20;
    final s = (workout?.status != null && workout!.status.isNotEmpty)
        ? workout.status
        : (status != null && status.isNotEmpty ? status : 'published');

    final v = workout?.videoUrl ?? videoUrl ?? '';

    try {
      if (isInitialized) {
        await Supabase.instance.client.from('workouts').upsert({
          'id': id,
          'title': t,
          'level': l,
          'duration_minutes': d,
          'status': s,
          'video_url': v,
          'created_at': DateTime.now().toIso8601String(),
        });
        debugPrint('⚡ Saved Workout "$t" ($id) to Supabase Database!');
        return true;
      }
    } catch (e) {
      debugPrint('⚡ Supabase Workout Save Note: $e');
    }
    return true;
  }

  /// 🗄️ Database: Stream Workouts
  static Stream<List<Workout>> streamWorkoutsFromSupabase() {
    try {
      if (isInitialized) {
        return Supabase.instance.client
            .from('workouts')
            .stream(primaryKey: ['id'])
            .map((list) => list.map((map) => Workout.fromMap(map)).toList());
      }
    } catch (_) {}
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
