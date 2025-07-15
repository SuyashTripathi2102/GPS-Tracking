class DBService {
  Future<List<Map<String, dynamic>>> fetchActivityRecords() async {
    // Mock data for demonstration; replace with SQLite fetch logic as needed
    return [
      {'steps': 1200, 'distance': 1.2, 'co2': 0.1},
      {'steps': 2500, 'distance': 2.1, 'co2': 0.18},
      {'steps': 1800, 'distance': 1.7, 'co2': 0.13},
      {'steps': 3200, 'distance': 2.8, 'co2': 0.22},
      {'steps': 4000, 'distance': 3.2, 'co2': 0.27},
      {'steps': 3500, 'distance': 2.9, 'co2': 0.21},
      {'steps': 2900, 'distance': 2.3, 'co2': 0.16},
    ];
  }
}
