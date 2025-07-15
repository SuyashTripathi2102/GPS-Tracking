import 'package:flutter/material.dart';
import 'package:fitness_app_fixed/widgets/chart_widget.dart';

class ProgressTabsScreen extends StatefulWidget {
  const ProgressTabsScreen({super.key});

  @override
  State<ProgressTabsScreen> createState() => _ProgressTabsScreenState();
}

class _ProgressTabsScreenState extends State<ProgressTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> tabs = ['Day', 'Week', 'Month'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs.map((label) => Tab(text: label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ChartWidget(period: 'day'),
          ChartWidget(period: 'week'),
          ChartWidget(period: 'month'),
        ],
      ),
    );
  }
}
