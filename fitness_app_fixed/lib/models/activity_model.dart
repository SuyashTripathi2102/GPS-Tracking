class ActivityModel {
  final int? id;
  final DateTime date;
  final int steps;
  final double distance; // in km
  final Duration activeTime; // in minutes

  ActivityModel({
    this.id,
    required this.date,
    required this.steps,
    required this.distance,
    required this.activeTime,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'steps': steps,
    'distance': distance,
    'activeTime': activeTime.inMinutes,
  };

  factory ActivityModel.fromMap(Map<String, dynamic> map) => ActivityModel(
    id: map['id'],
    date: DateTime.parse(map['date']),
    steps: map['steps'],
    distance: map['distance'],
    activeTime: Duration(minutes: map['activeTime']),
  );
}
