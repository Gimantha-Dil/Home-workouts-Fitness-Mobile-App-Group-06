import 'workout_model.dart';

class MockData {
  static final List<Exercise> sampleExercises = [
    const Exercise(
      id: 'e1',
      name: 'Bodyweight Squats',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      instructions: [
        'Stand with feet shoulder-width apart.',
        'Keep your back straight and core tight.',
        'Lower your hips back and down like sitting in a chair.',
        'Push back up to the starting position.',
      ],
      tip: 'Keep your knees behind your toes.',
    ),
    const Exercise(
      id: 'e2',
      name: 'Push Ups (Knee)',
      sets: 3,
      reps: 10,
      restSeconds: 45,
      instructions: [
        'Start in a kneeling position with hands slightly wider than shoulder-width.',
        'Keep your back straight and core tight.',
        'Lower your chest towards the floor.',
        'Push back up to the starting position.',
      ],
      tip: 'Keep your neck in a neutral position.',
    ),
    const Exercise(id: 'e3', name: 'Glute Bridge', sets: 3, reps: 15, restSeconds: 45),
    const Exercise(id: 'e4', name: 'Plank', sets: 3, reps: 20, restSeconds: 30),
    const Exercise(id: 'e5', name: 'Walking Lunges', sets: 3, reps: 12, restSeconds: 45),
    const Exercise(id: 'e6', name: 'Mountain Climbers', sets: 3, reps: 30, restSeconds: 30),
  ];

  static final List<Workout> workouts = [
    Workout(
      id: 'w1',
      title: 'Full Body Beginner',
      description:
          'A simple full body workout to help you improve, strengthen and get started with fitness.',
      level: 'Beginner',
      durationMinutes: 20,
      goal: 'Weight Loss',
      status: 'Published',
      exercises: sampleExercises,
    ),
    Workout(
      id: 'w2',
      title: 'Lower Body & Core',
      description: 'Focus on legs, glutes and core stability.',
      level: 'Beginner',
      durationMinutes: 25,
      goal: 'Build Strength',
      status: 'Published',
      exercises: sampleExercises.take(4).toList(),
    ),
    Workout(
      id: 'w3',
      title: 'Upper Body Toning',
      description: 'Tone and strengthen your upper body.',
      level: 'Intermediate',
      durationMinutes: 20,
      goal: 'Improve Fitness',
      status: 'Published',
      exercises: sampleExercises.take(3).toList(),
    ),
    Workout(
      id: 'w4',
      title: 'Cardio & Mobility',
      description: 'Light cardio to raise your heart rate and improve mobility.',
      level: 'Beginner',
      durationMinutes: 15,
      goal: 'Improve Fitness',
      status: 'Under Review',
      exercises: sampleExercises.take(5).toList(),
    ),
  ];

  static final List<SafetyGuide> safetyGuides = [
    const SafetyGuide(
      id: 's1',
      title: 'General Safety Tips',
      category: 'General',
      content: 'Important tips for safe home workouts.',
    ),
    const SafetyGuide(
      id: 's2',
      title: 'Warm-up Guide',
      category: 'Warm-up',
      content:
          'Warm-up increases blood flow, improves flexibility and reduces the risk of injury. '
          'It prepares your body for exercise.\n\n1. Arm Circles - 1 minute\n2. Leg Swings - 1 minute\n'
          '3. Marching in Place - 2 minutes\n4. Dynamic Stretching - 2 minutes',
    ),
    const SafetyGuide(
      id: 's3',
      title: 'Cool-down Guide',
      category: 'Cool-down',
      content:
          'Cool-down helps your heart rate return to normal, reduces muscle soreness and '
          'improves flexibility.\n\n1. Light Walking - 2-3 minutes\n2. Hamstring Stretch - 1 minute\n'
          '3. Quad Stretch - 1 minute\n4. Deep Breathing - 1-2 minutes',
    ),
    const SafetyGuide(
      id: 's4',
      title: 'Exercise Precautions',
      category: 'Precautions',
      content:
          'Listen to your body. Avoid overexertion. Stay hydrated. Use proper form. '
          'Wear suitable clothing. Consult a professional if you have a medical condition.',
    ),
    const SafetyGuide(
      id: 's5',
      title: 'Warning Signs',
      category: 'Precautions',
      content:
          'Stop exercising immediately if you experience: chest pain or tightness, shortness of '
          'breath, dizziness or fainting, severe muscle pain, joint pain or swelling, nausea or vomiting.',
    ),
  ];

  static const Map<String, String> healthConsiderations = {
    'Heart Conditions': 'People with heart conditions should consult a doctor before starting.',
    'Diabetes': 'Monitor blood sugar levels during exercise.',
    'Joint Problems': 'Use low-impact exercises and avoid high-impact movements.',
    'Pregnancy': 'Follow safe workout guidelines and get medical advice.',
    'Chronic Illnesses': 'Manage your condition and exercise within safe limits.',
    'Previous Injuries': 'Be cautious and follow rehabilitation guidelines.',
  };
}
