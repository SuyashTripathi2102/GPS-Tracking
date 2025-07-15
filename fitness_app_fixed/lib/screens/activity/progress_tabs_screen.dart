import 'package:flutter/material.dart';
import 'progress_chart_screen.dart';

class ProgressTabsScreen extends StatefulWidget {
  const ProgressTabsScreen({super.key});

  @override
  State<ProgressTabsScreen> createState() => _ProgressTabsScreenState();
}

class _ProgressTabsScreenState extends State<ProgressTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> types = ['CO₂', 'Calories', 'Steps', 'Distance'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: types.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress"),
        bottom: TabBar(
          controller: _tabController,
          tabs: types.map((e) => Tab(text: e)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: types.map((type) {
          return ProgressChartScreen(type: type);
        }).toList(),
      ),
    );
  }
}
