class TrainingData {
  String name;
  Map<String, int> exercises = {};

  TrainingData(this.name, this.exercises);

  Map<String, dynamic> toJson() {
    return {
      "exercises": exercises,
    };
  }
}

// ignore: type_annotate_public_apis
TrainingData createTrainingData(name, data) {
  if (name is String && data is Map<String, int>) {
    final TrainingData trainingData = TrainingData(name, data);

    return trainingData;
  } else {
    return TrainingData("", {});
  }
}