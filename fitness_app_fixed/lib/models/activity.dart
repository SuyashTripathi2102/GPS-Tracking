class Activity {
  final String day;
  final int steps;

  Activity({required this.day, required this.steps});

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(day: map['day'], steps: map['steps']);
  }
}
