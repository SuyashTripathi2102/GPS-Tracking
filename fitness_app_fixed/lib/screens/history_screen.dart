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
    try {
      final data = await DBHelper.getAllSessions();
      if (data.isEmpty) {
        // Insert demo data if empty
        await DBHelper.insertSession(
          userId: 'demo',
          startTime: DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
          endTime: DateTime.now()
              .subtract(const Duration(days: 2, hours: -1))
              .toIso8601String(),
          distance: 3200,
          status: 'completed',
        );
        await DBHelper.insertSession(
          userId: 'demo',
          startTime: DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          endTime: DateTime.now()
              .subtract(const Duration(days: 1, hours: -1))
              .toIso8601String(),
          distance: 4200,
          status: 'completed',
        );
        await DBHelper.insertSession(
          userId: 'demo',
          startTime: DateTime.now().toIso8601String(),
          endTime: DateTime.now()
              .add(const Duration(hours: 1))
              .toIso8601String(),
          distance: 5100,
          status: 'completed',
        );
        // Reload after inserting demo data
        final afterDemo = await DBHelper.getAllSessions();
        if (afterDemo.isEmpty) {
          print('DB ERROR: Demo data insertion failed, DB is still empty!');
        }
        return _loadSessions();
      }
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
    } catch (e, st) {
      print('DB ERROR: $e\n$st');
      setState(() {
        _sessions = [];
      });
    }
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
      body: _sessions.isEmpty
          ? Center(
              child: Text(
                'No session data found.\nIf you see this after a few seconds, there may be a database error.\nCheck logs for details.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade400, fontSize: 16),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
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
                  // 1. Progress Overview Section Header
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      top: 16,
                      bottom: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bar_chart,
                          color: Colors.deepPurple,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Progress Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 2. Chart in Card with Modern Style
                  if (_distanceSpots.isNotEmpty)
                    Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          16,
                          16,
                          32,
                        ), // increased bottom padding
                        child: (_distanceSpots.every((spot) => spot.y == 0))
                            ? SizedBox(
                                height: 180,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.directions_walk,
                                        size: 48,
                                        color: Colors.deepPurple.shade100,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'No activity yet',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 240,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY:
                                        _distanceSpots
                                            .map((e) => e.y)
                                            .reduce((a, b) => a > b ? a : b) +
                                        0.5,
                                    minY: 0,
                                    barGroups: List.generate(
                                      _distanceSpots.length,
                                      (i) {
                                        final isBest = i == _bestSessionIndex;
                                        final isWorst = i == _worstSessionIndex;
                                        final colorGradient = isBest
                                            ? [Colors.greenAccent, Colors.green]
                                            : isWorst
                                            ? [Colors.redAccent, Colors.red]
                                            : [
                                                Colors.deepPurpleAccent,
                                                Colors.blueAccent,
                                              ];
                                        return BarChartGroupData(
                                          x: i,
                                          barRods: [
                                            BarChartRodData(
                                              toY: _distanceSpots[i].y,
                                              gradient: LinearGradient(
                                                colors: colorGradient,
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                              ),
                                              width: 36,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              rodStackItems: [],
                                              backDrawRodData:
                                                  BackgroundBarChartRodData(
                                                    show: true,
                                                    toY: 0,
                                                    color: Colors
                                                        .deepPurple
                                                        .shade50,
                                                  ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 44,
                                          getTitlesWidget: (value, meta) {
                                            if (value % 1 != 0)
                                              return SizedBox.shrink();
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8.0,
                                              ),
                                              child: Text(
                                                '${value.toStringAsFixed(1)}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.deepPurple,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        axisNameWidget: Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8.0,
                                          ),
                                          child: Text(
                                            'Distance (km)',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                        ),
                                        axisNameSize: 28,
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize:
                                              40, // increased from default
                                          getTitlesWidget: (value, meta) {
                                            final idx = value.toInt();
                                            if (idx < 0 ||
                                                idx >= _sessions.length)
                                              return const SizedBox.shrink();
                                            if (_sessions.length > 6 &&
                                                idx % 2 != 0)
                                              return const SizedBox.shrink();
                                            final date =
                                                DateTime.tryParse(
                                                  _sessions[idx]['start_time'] ??
                                                      '',
                                                ) ??
                                                DateTime(2000);
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: Text(
                                                DateFormat(
                                                  'MM/dd',
                                                ).format(date),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: 1,
                                      getDrawingHorizontalLine: (value) =>
                                          FlLine(
                                            color: Colors.deepPurple.shade50,
                                            strokeWidth: 1,
                                          ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipItem:
                                            (group, groupIndex, rod, rodIndex) {
                                              final session =
                                                  _sessions[group.x.toInt()];
                                              return BarTooltipItem(
                                                'Session #${session['id']}\n${(rod.toY).toStringAsFixed(2)} km',
                                                const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                  swapAnimationDuration: Duration(
                                    milliseconds: 900,
                                  ),
                                  swapAnimationCurve: Curves.easeOutCubic,
                                ),
                              ),
                      ),
                    ),
                  // 3. Filter Row as Card with Modern Buttons/Inputs
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickDateRange,
                            icon: const Icon(
                              Icons.date_range,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Filter by Date",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: "Min Distance (m)",
                                isDense: true,
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) => setState(
                                () => _minDistanceFilter = double.tryParse(v),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: "Max Distance (m)",
                                isDense: true,
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) => setState(
                                () => _maxDistanceFilter = double.tryParse(v),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.deepPurple,
                            ),
                            onPressed: _clearFilters,
                            tooltip: "Clear filters",
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 4. Session Cards Redesign
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Your Sessions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (_, index) {
                      final session = filtered[index];
                      final start =
                          DateTime.tryParse(session['start_time'] ?? '') ??
                          DateTime(2000);
                      final formattedDate = DateFormat(
                        'MMM d, yyyy – h:mm a',
                      ).format(start);
                      final isBest =
                          _bestSessionIndex != null &&
                          session['id'] == _sessions[_bestSessionIndex!]['id'];
                      final isWorst =
                          _worstSessionIndex != null &&
                          session['id'] == _sessions[_worstSessionIndex!]['id'];
                      final accentColor = isBest
                          ? Colors.green
                          : isWorst
                          ? Colors.red
                          : Colors.deepPurple;
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              border: Border(
                                left: BorderSide(color: accentColor, width: 6),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: accentColor.withOpacity(0.15),
                                radius: 26,
                                child: Icon(
                                  Icons.directions_run,
                                  color: accentColor,
                                  size: 28,
                                ),
                              ),
                              title: Text(
                                'Session #${session['id']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: accentColor,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: accentColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${(session['distance'] / 1000).toStringAsFixed(2)} km',
                                          style: TextStyle(
                                            color: accentColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey.shade400,
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SessionDetailScreen(
                                    sessionId: session['id'],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
