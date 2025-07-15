import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin {
  String selectedPeriod = 'Daily';
  int selectedTabIndex = 0;

  final List<String> periods = ['Daily', 'Weekly', 'Monthly'];
  final List<String> tabs = ['Steps', 'Distance', 'CO₂'];

  final List<List<FlSpot>> chartData = [
    [
      FlSpot(0, 1000),
      FlSpot(1, 2000),
      FlSpot(2, 1800),
      FlSpot(3, 3000),
    ], // Steps
    [
      FlSpot(0, 1.2),
      FlSpot(1, 1.8),
      FlSpot(2, 2.5),
      FlSpot(3, 3.1),
    ], // Distance
    [FlSpot(0, 0.1), FlSpot(1, 0.2), FlSpot(2, 0.3), FlSpot(3, 0.25)], // CO₂
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget buildDropdown() {
    return DropdownButton<String>(
      value: selectedPeriod,
      borderRadius: BorderRadius.circular(10),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      items: periods.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(fontSize: 16)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedPeriod = newValue;
          });
        }
      },
    );
  }

  LineChartData generateChart(List<FlSpot> spots) {
    return LineChartData(
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 30),
        ),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.purple,
          barWidth: 4,
          belowBarData: BarAreaData(
            show: true,
            color: Colors.purple.withOpacity(0.2),
          ),
          dotData: FlDotData(show: false),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(16.0), child: buildDropdown()),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.purple,
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            tabs: tabs.map((e) => Tab(text: e)).toList(),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LineChart(generateChart(chartData[selectedTabIndex])),
            ),
          ),
        ],
      ),
    );
  }
}
