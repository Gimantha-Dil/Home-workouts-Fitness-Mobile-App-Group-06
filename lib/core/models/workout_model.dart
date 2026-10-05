class Exercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final String difficulty;
  final List<String> instructions;
  final String tip;

  const Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.difficulty = 'Beginner',
    this.instructions = const [],
    this.tip = '',
  });
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
