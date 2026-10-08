class Exercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final String difficulty;
  final List<String> instructions;
  final String tip;
  final String? videoUrl;

  const Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.difficulty = 'Beginner',
    this.instructions = const [],
    this.tip = '',
    this.videoUrl,
  });

  Map<String, dynamic> toMap() {
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

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      sets: map['sets'] ?? 3,
      reps: map['reps'] ?? 10,
      restSeconds: map['restSeconds'] ?? 30,
      difficulty: map['difficulty'] ?? 'Beginner',
      instructions: List<String>.from(map['instructions'] ?? []),
      tip: map['tip'] ?? '',
      videoUrl: map['videoUrl'],
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
  final List<Exercise> exercises;

  bool get hasExercises => exercises.isNotEmpty;

  Exercise? exerciseAt(int i) => (i >= 0 && i < exercises.length) ? exercises[i] : null;

  const Workout({
    required this.id,
    required this.title,
    this.description = '',
    required this.level,
    required this.durationMinutes,
    this.goal = 'General Fitness',
    this.status = 'Draft',
    this.imageUrl = 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400&auto=format&fit=crop',
    this.exercises = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
      'durationMinutes': durationMinutes,
      'goal': goal,
      'status': status,
      'imageUrl': imageUrl,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    final list = <Exercise>[];
    if (map['exercises'] is List) {
      for (final e in map['exercises'] as List) {
        if (e is Map) {
          try {
            list.add(Exercise.fromMap(Map<String, dynamic>.from(e)));
          } catch (_) {}
        }
      }
    }
    return Workout(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      level: map['level'] ?? 'Beginner',
      durationMinutes: map['durationMinutes'] ?? 15,
      goal: map['goal'] ?? 'General Fitness',
      status: map['status'] ?? 'Draft',
      imageUrl: map['imageUrl'] ?? 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400&auto=format&fit=crop',
      exercises: list,
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
