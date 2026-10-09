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
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      sets: (map['sets'] is int) ? map['sets'] : (int.tryParse(map['sets']?.toString() ?? '') ?? 3),
      reps: (map['reps'] is int) ? map['reps'] : (int.tryParse(map['reps']?.toString() ?? '') ?? 10),
      restSeconds: (map['restSeconds'] is int)
          ? map['restSeconds']
          : (map['rest_seconds'] is int
              ? map['rest_seconds']
              : (int.tryParse(map['restSeconds']?.toString() ?? '') ?? 30)),
      difficulty: map['difficulty']?.toString() ?? 'Beginner',
      instructions: map['instructions'] is List
          ? List<String>.from(map['instructions'].map((e) => e.toString()))
          : [],
      tip: map['tip']?.toString() ?? '',
      videoUrl: map['videoUrl']?.toString() ?? map['video_url']?.toString(),
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
  final String? videoUrl;
  final List<Exercise> exercises;

  bool get hasExercises => exercises.isNotEmpty;
  bool get isPublished => status.toLowerCase() == 'published';

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
    this.videoUrl,
    this.exercises = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
      'duration_minutes': durationMinutes,
      'durationMinutes': durationMinutes,
      'goal': goal,
      'status': status,
      'image_url': imageUrl,
      'imageUrl': imageUrl,
      'video_url': videoUrl,
      'videoUrl': videoUrl,
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

    int parseDuration(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 20;
      return 20;
    }

    return Workout(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Untitled Workout',
      description: map['description']?.toString() ?? '',
      level: map['level']?.toString() ?? 'Beginner',
      durationMinutes: parseDuration(map['duration_minutes'] ?? map['durationMinutes']),
      goal: map['goal']?.toString() ?? 'General Fitness',
      status: map['status']?.toString() ?? 'Draft',
      imageUrl: map['image_url']?.toString() ?? map['imageUrl']?.toString() ?? 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400&auto=format&fit=crop',
      videoUrl: map['video_url']?.toString() ?? map['videoUrl']?.toString(),
      exercises: list,
    );
  }
}

class SafetyGuide {
  final String id;
  final String title;
  final String category;
  final String content;
  final String author;
  final String status;
  final DateTime? date;

  const SafetyGuide({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    this.author = 'Healthcare Advisor',
    this.status = 'Published',
    this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'content': content,
      'author': author,
      'status': status,
      'date': date?.toIso8601String(),
    };
  }

  factory SafetyGuide.fromMap(Map<String, dynamic> map) {
    return SafetyGuide(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? 'General',
      content: map['content'] ?? '',
      author: map['author'] ?? 'Healthcare Advisor',
      status: map['status'] ?? 'Published',
      date: map['date'] != null ? DateTime.tryParse(map['date'].toString()) : null,
    );
  }
}
