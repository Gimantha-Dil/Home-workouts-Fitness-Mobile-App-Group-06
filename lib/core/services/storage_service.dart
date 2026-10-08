import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  static const String _envUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _envKey = String.fromEnvironment('SUPABASE_ANON_KEY');


  static const String defaultUrl = 'https://ctguxkodnxxntloshlls.supabase.co';
  static const String defaultAnonKey = 'sb_publishable_16YzWxaZ-YIn4bCH1D4ZcA_gK67V4-2';

  static String get supabaseUrl {
    final raw = _envUrl.isNotEmpty ? _envUrl : defaultUrl;
    return raw.replaceAll('/rest/v1/', '').replaceAll('/rest/v1', '');
  }

  static String get supabaseAnonKey => _envKey.isNotEmpty ? _envKey : defaultAnonKey;

  static bool _initialized = false;

  /// Initialize Supabase Client for Storage only
  static Future<void> initializeStorage() async {
    final url = supabaseUrl;
    final key = supabaseAnonKey;

    if (url.isEmpty || key.isEmpty) {
      debugPrint('⚠️ Warning: SUPABASE_URL or SUPABASE_ANON_KEY is missing.');
      return;
    }

    try {
      await Supabase.initialize(
        url: url,
        anonKey: key,
      );
      _initialized = true;
      debugPrint('⚡ Supabase Storage initialized successfully ($url).');
    } catch (e) {
      debugPrint('⚠️ Supabase Storage init note: $e');
    }
  }

  static SupabaseClient get _client {
    if (!_initialized) {
      throw 'Supabase Storage is not initialized. Ensure SUPABASE_URL and SUPABASE_ANON_KEY are valid.';
    }
    return Supabase.instance.client;
  }

  /// Upload User Profile Photo to `user-photos` bucket
  static Future<String> uploadProfilePhoto({
    required List<int> bytes,
    required String uid,
    String format = 'jpg',
  }) async {
    const maxBytes = 5 * 1024 * 1024; // 5 MB
    if (bytes.length > maxBytes) {
      throw 'Image size exceeds the maximum limit of 5 MB.';
    }

    final ext = format.toLowerCase().replaceAll('.', '');
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
      throw 'Unsupported image format ($ext). Allowed formats: JPG, PNG, WEBP.';
    }

    final mimeType = ext == 'png' ? 'image/png' : ext == 'webp' ? 'image/webp' : 'image/jpeg';
    final path = 'avatars/$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';

    try {
      await _client.storage.from('user-photos').uploadBinary(
        path,
        Uint8List.fromList(bytes),
        fileOptions: FileOptions(contentType: mimeType, upsert: true),
      );

      return _client.storage.from('user-photos').getPublicUrl(path);
    } catch (e) {
      throw 'Failed to upload profile photo to Supabase: ${e.toString()}';
    }
  }

  /// Upload Exercise Video to `exercise-videos` bucket
  static Future<String> uploadExerciseVideo({
    required List<int> bytes,
    required String uid,
    required String workoutId,
    String fileName = 'workout_video.mp4',
  }) async {
    const maxBytes = 50 * 1024 * 1024; // 50 MB
    if (bytes.length > maxBytes) {
      throw 'Video size exceeds the maximum limit of 50 MB.';
    }

    final path = 'videos/$uid/$workoutId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    try {
      await _client.storage.from('exercise-videos').uploadBinary(
        path,
        Uint8List.fromList(bytes),
        fileOptions: const FileOptions(contentType: 'video/mp4', upsert: true),
      );

      return _client.storage.from('exercise-videos').getPublicUrl(path);
    } catch (e) {
      throw 'Failed to upload exercise video to Supabase: ${e.toString()}';
    }
  }

  /// Upload Verification Document to `verification-docs` bucket
  static Future<String> uploadVerificationDoc({
    required List<int> bytes,
    required String uid,
    required String fileName,
  }) async {
    const maxBytes = 10 * 1024 * 1024; // 10 MB
    if (bytes.length > maxBytes) {
      throw 'Document size exceeds the maximum limit of 10 MB.';
    }

    final cleanName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final ext = cleanName.contains('.') ? cleanName.split('.').last.toLowerCase() : 'pdf';

    String mimeType = 'application/pdf';
    if (['jpg', 'jpeg'].contains(ext)) {
      mimeType = 'image/jpeg';
    } else if (ext == 'png') {
      mimeType = 'image/png';
    }

    final path = 'docs/$uid/${DateTime.now().millisecondsSinceEpoch}_$cleanName';

    try {
      await _client.storage.from('verification-docs').uploadBinary(
        path,
        Uint8List.fromList(bytes),
        fileOptions: FileOptions(contentType: mimeType, upsert: true),
      );

      // Bucket එක public බැවින් කෙළින්ම URL එක ලබා ගත හැක (නැතහොත් signed url)
      try {
        return await _client.storage.from('verification-docs').createSignedUrl(
          path,
          60 * 60 * 24 * 365,
        );
      } catch (_) {
        return _client.storage.from('verification-docs').getPublicUrl(path);
      }
    } catch (e) {
      throw 'Failed to upload verification document: ${e.toString()}';
    }
  }
}