import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';
import 'session_detail_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _sessions = [];
  double _totalDistance = 0;
  double _averageDistance = 0;
  List<FlSpot> _distanceSpots = [];
  int? _bestSessionIndex;
  int? _worstSessionIndex;
  DateTimeRange? _dateFilter;
  double? _minDistanceFilter;
  double? _maxDistanceFilter;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final data = await DBHelper.getAllSessions();
    double total = 0;
    List<FlSpot> spots = [];
    double? bestDist;
    double? worstDist;
    int? bestIdx;
    int? worstIdx;
    for (int i = 0; i < data.length; i++) {
      final dist = (data[i]['distance'] as num?)?.toDouble() ?? 0;
      total += dist;
      spots.add(FlSpot(i.toDouble(), dist / 1000)); // convert to km
      if (bestDist == null || dist > bestDist) {
        bestDist = dist;
        bestIdx = i;
      }
      if (worstDist == null || dist < worstDist) {
        worstDist = dist;
        worstIdx = i;
      }
    }
    setState(() {
      _sessions = data;
      _totalDistance = total;
      _averageDistance = data.isNotEmpty ? total / data.length : 0;
      _distanceSpots = spots;
      _bestSessionIndex = bestIdx;
      _worstSessionIndex = worstIdx;
    });
  }

  List<Map<String, dynamic>> get _filteredSessions {
    return _sessions.where((session) {
      final date =
          DateTime.tryParse(session['start_time'] ?? '') ?? DateTime(2000);
      final dist = (session['distance'] as num?)?.toDouble() ?? 0;
      bool dateOk =
          _dateFilter == null ||
          (_dateFilter!.start.isBefore(date) && _dateFilter!.end.isAfter(date));
      bool minOk = _minDistanceFilter == null || dist >= _minDistanceFilter!;
      bool maxOk = _maxDistanceFilter == null || dist <= _maxDistanceFilter!;
      return dateOk && minOk && maxOk;
    }).toList();
  }

  void _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateFilter,
    );
    if (picked != null) setState(() => _dateFilter = picked);
  }

  void _clearFilters() {
    setState(() {
      _dateFilter = null;
      _minDistanceFilter = null;
      _maxDistanceFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSessions;
    return Scaffold(
      appBar: AppBar(title: const Text("Session History")),
      body: Column(
        children: [
          if (_sessions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Total Sessions",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(_sessions.length.toString()),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Total Distance",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${(_totalDistance / 1000).toStringAsFixed(2)} km",
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Avg Distance",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${(_averageDistance / 1000).toStringAsFixed(2)} km",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_bestSessionIndex != null && _worstSessionIndex != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Chip(
                      label: Text(
                        "Best: #${_sessions[_bestSessionIndex!]['id']} (${(_sessions[_bestSessionIndex!]['distance'] / 1000).toStringAsFixed(2)} km)",
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        "Worst: #${_sessions[_worstSessionIndex!]['id']} (${(_sessions[_worstSessionIndex!]['distance'] / 1000).toStringAsFixed(2)} km)",
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickDateRange,
                    icon: const Icon(Icons.date_range),
                    label: const Text("Filter by Date"),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 140,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: "Min Distance (m)",
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => setState(
                        () => _minDistanceFilter = double.tryParse(v),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 140,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: "Max Distance (m)",
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => setState(
                        () => _maxDistanceFilter = double.tryParse(v),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearFilters,
                    tooltip: "Clear filters",
                  ),
                ],
              ),
            ),
          ),
          if (_distanceSpots.isNotEmpty)
            SizedBox(
              height: 180,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: BarChart(
                  BarChartData(
                    barGroups: List.generate(_distanceSpots.length, (i) {
                      final isBest = i == _bestSessionIndex;
                      final isWorst = i == _worstSessionIndex;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: _distanceSpots[i].y,
                            color: isBest
                                ? Colors.green
                                : isWorst
                                ? Colors.red
                                : Colors.deepPurple,
                            width: 18,
                            borderRadius: BorderRadius.circular(6),
                            rodStackItems: [],
                          ),
                        ],
                        showingTooltipIndicators: [0],
                      );
                    }),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= _sessions.length)
                              return const SizedBox.shrink();
                            final date =
                                DateTime.tryParse(
                                  _sessions[idx]['start_time'] ?? '',
                                ) ??
                                DateTime(2000);
                            return Text(
                              DateFormat('MM/dd').format(date),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final session = _sessions[group.x.toInt()];
                          return BarTooltipItem(
                            'Session #${session['id']}\n${(rod.toY).toStringAsFixed(2)} km',
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, index) {
                final session = filtered[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text("Session #${session['id']}"),
                    subtitle: Text(
                      "Start: ${session['start_time']}\nDistance: ${session['distance'].toStringAsFixed(2)} m",
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SessionDetailScreen(sessionId: session['id']),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
