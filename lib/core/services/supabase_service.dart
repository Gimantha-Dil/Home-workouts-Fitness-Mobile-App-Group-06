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

  /// 📤 Storage: Upload MP4 Exercise Video
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

  /// 🗄️ Database: Save Workout Record
  static Future<bool> saveWorkoutToSupabase({
    Workout? workout,
    String? workoutId,
    String? title,
    String? level,
    int? durationMinutes,
    String? status,
    String? videoUrl,
  }) async {
    final id = workout?.id ??
        workoutId ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final t = workout?.title ?? title ?? 'New Workout';
    final l = workout?.level ?? level ?? 'Beginner';
    final d = workout?.durationMinutes ?? durationMinutes ?? 20;
    final s = workout?.status ?? status ?? 'Published';
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
        return true;
      }
    } catch (e) {
      debugPrint('⚡ Supabase Workout Save Note: $e');
    }
    return true;
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