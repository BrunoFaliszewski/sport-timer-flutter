class Set {
  String name;
  Map<String, int> exercises = {};

  Set(this.name, this.exercises);

  Map<String, dynamic> toJson() {
    return {
      "exercises": exercises, // zamiat zapisywać dane po id, zapisywać dane po name of set
    };
  }
}