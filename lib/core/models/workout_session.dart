import 'workout_model.dart';

class SetResult {
  final int exerciseIndex;
  final int setNumber;
  final int targetReps;
  final int repsDone;
  final int durationSeconds;
  final bool completed;

  const SetResult({
    required this.exerciseIndex,
    required this.setNumber,
    required this.targetReps,
    required this.repsDone,
    required this.durationSeconds,
    this.completed = true,
  });
}

class WorkoutSession {
  final Workout workout;
  int exerciseIndex;
  int currentSet;
  final List<SetResult> setResults;
  final DateTime startedAt;

  WorkoutSession({
    required this.workout,
    this.exerciseIndex = 0,
    this.currentSet = 1,
    List<SetResult>? setResults,
    DateTime? startedAt,
  })  : setResults = setResults ?? [],
        startedAt = startedAt ?? DateTime.now();

  Exercise? get currentExercise => workout.exerciseAt(exerciseIndex);

  int get totalExercises => workout.exercises.length;

  bool get isLastSet {
    final ex = currentExercise;
    if (ex == null) return true;
    return currentSet >= ex.sets;
  }

  bool get isLastExercise => exerciseIndex >= totalExercises - 1;

  void completeSet({required int repsDone, required int durationSeconds}) {
    final ex = currentExercise;
    final targetReps = ex?.reps ?? 10;

    setResults.add(
      SetResult(
        exerciseIndex: exerciseIndex,
        setNumber: currentSet,
        targetReps: targetReps,
        repsDone: repsDone,
        durationSeconds: durationSeconds,
      ),
    );
  }

  bool next() {
    if (!isLastSet) {
      currentSet++;
      return false; // Stay on same exercise, next set
    }

    if (!isLastExercise) {
      exerciseIndex++;
      currentSet = 1;
      return false; // Next exercise, first set
    }

    return true; // Workout finished
  }

  bool previous() {
    if (setResults.isNotEmpty) {
      setResults.removeLast();
    }

    if (currentSet > 1) {
      currentSet--;
      return true;
    }

    if (exerciseIndex > 0) {
      exerciseIndex--;
      final prevEx = currentExercise;
      currentSet = prevEx?.sets ?? 1;
      return true;
    }

    return false; // Already at start
  }

  int get totalCompletedReps {
    return setResults.fold(0, (sum, res) => sum + res.repsDone);
  }

  int get totalActiveDurationSeconds {
    return setResults.fold(0, (sum, res) => sum + res.durationSeconds);
  }
}
