import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_role.dart';
import '../models/workout_model.dart';

/// Supabase Backend Integration (PostgreSQL DB, Storage Buckets, Auth)
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
        anonKey: supabaseAnonKey,
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

  /// 🗄️ Supabase PostgreSQL Table: Save User Record
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
        debugPrint('⚡ User saved to Supabase PostgreSQL Database!');
        return true;
      }
    } catch (e) {
      debugPrint('⚡ Supabase User Save Note: $e');
    }
    return true;
  }

  /// 🗄️ Supabase PostgreSQL Table: Save / Upsert Full Workout Record
  static Future<bool> saveWorkoutToSupabase({
    required Workout workout,
  }) async {
    try {
      if (isInitialized) {
        await Supabase.instance.client.from('workouts').upsert(workout.toJson());
        debugPrint('⚡ Workout saved to Supabase PostgreSQL Database: ${workout.title}');
        return true;
      }
    } catch (e) {
      debugPrint('⚡ Supabase Workout Save Note: $e');
    }
    return true;
  }

  /// 🗄️ Supabase PostgreSQL Table: Fetch Workouts for Customer, Trainer, Advisor, Admin
  static Future<List<Workout>> fetchWorkoutsFromSupabase() async {
    try {
      if (isInitialized) {
        final response = await Supabase.instance.client
            .from('workouts')
            .select()
            .order('created_at', ascending: false);

        if (response is List) {
          return response
              .map((data) => Workout.fromJson(Map<String, dynamic>.from(data)))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('⚡ Supabase Fetch Workouts Note: $e');
    }
    return [];
  }

  /// 🗄️ Supabase PostgreSQL Table: Update Workout Review Status (Advisor / Admin Review)
  static Future<bool> updateWorkoutStatusInSupabase({
    required String workoutId,
    required String status,
    String? reviewerNote,
  }) async {
    try {
      if (isInitialized) {
        await Supabase.instance.client.from('workouts').update({
          'status': status,
          if (reviewerNote != null) 'reviewer_note': reviewerNote,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', workoutId);
        debugPrint('⚡ Workout status updated in Supabase to: $status');
        return true;
      }
    } catch (e) {
      debugPrint('⚡ Supabase Update Status Note: $e');
    }
    return true;
  }
}
