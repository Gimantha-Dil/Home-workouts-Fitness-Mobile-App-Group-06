class Exercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final String difficulty;
  final List<String> instructions;
  final String tip;
  final String videoUrl;

  const Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.difficulty = 'Beginner',
    this.instructions = const [],
    this.tip = '',
    this.videoUrl = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
      'difficulty': difficulty,
      'instructions': instructions,
      'tip': tip,
      'videoUrl': videoUrl,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? 'e_0',
      name: json['name'] ?? 'Exercise',
      sets: json['sets'] ?? 3,
      reps: json['reps'] ?? 10,
      restSeconds: json['restSeconds'] ?? json['rest_seconds'] ?? 45,
      difficulty: json['difficulty'] ?? 'Beginner',
      instructions: json['instructions'] != null
          ? List<String>.from(json['instructions'])
          : const [],
      tip: json['tip'] ?? '',
      videoUrl: json['videoUrl'] ?? json['video_url'] ?? '',
    );
  }
}

class Workout {
  final String id;
  final String title;
  final String description;
  final String level;
  final int durationMinutes;
  final String goal;
  final String status;
  final String imageUrl;
  final String videoUrl;
  final String reviewerNote;
  final List<Exercise> exercises;

  const Workout({
    required this.id,
    required this.title,
    this.description = '',
    required this.level,
    required this.durationMinutes,
    this.goal = 'General Fitness',
    this.status = 'Draft',
    this.imageUrl = 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400&auto=format&fit=crop',
    this.videoUrl = '',
    this.reviewerNote = '',
    this.exercises = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
      'duration_minutes': durationMinutes,
      'goal': goal,
      'status': status,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'reviewer_note': reviewerNote,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    List<Exercise> exList = [];
    if (json['exercises'] != null) {
      if (json['exercises'] is List) {
        exList = (json['exercises'] as List)
            .map((e) => Exercise.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
    return Workout(
      id: json['id'] ?? 'w_0',
      title: json['title'] ?? 'Workout',
      description: json['description'] ?? '',
      level: json['level'] ?? 'Beginner',
      durationMinutes: json['duration_minutes'] ?? json['duration'] ?? 20,
      goal: json['goal'] ?? 'General Fitness',
      status: json['status'] ?? 'Draft',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400&auto=format&fit=crop',
      videoUrl: json['video_url'] ?? json['videoUrl'] ?? '',
      reviewerNote: json['reviewer_note'] ?? json['reviewerNote'] ?? '',
      exercises: exList,
    );
  }
}

class SafetyGuide {
  final String id;
  final String title;
  final String category;
  final String content;
  final String status;

  const SafetyGuide({
    required this.id,
    required this.title,
    required this.category,
    this.content = '',
    this.status = 'Published',
  });
}

class AppNotification {
  final String id;
  final String title;
  final String time;
  final bool enabled;

  const AppNotification({
    required this.id,
    required this.title,
    required this.time,
    this.enabled = true,
  });
}
