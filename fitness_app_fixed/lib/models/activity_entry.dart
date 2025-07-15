class ActivityEntry {
  final int id;
  final DateTime date;
  final int steps;
  final double distanceKm;
  final int activeMinutes;

  ActivityEntry({
    required this.id,
    required this.date,
    required this.steps,
    required this.distanceKm,
    required this.activeMinutes,
  });

  factory ActivityEntry.fromMap(Map<String, dynamic> map) {
    return ActivityEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      steps: map['steps'],
      distanceKm: map['distance_km'],
      activeMinutes: map['active_minutes'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'steps': steps,
    'distance_km': distanceKm,
    'active_minutes': activeMinutes,
  };
}
