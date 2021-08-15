class CurrentTrainingData {
  Map<String, int> exercises = {};

  void addExercise(String name, int time) {
    exercises[name] = time;
  }

  void removeExercise(String name, int time) {
    exercises.remove(name);
  }

  void reset() {
    exercises.clear();
    // ignore: avoid_print
    print(exercises);
  }
}